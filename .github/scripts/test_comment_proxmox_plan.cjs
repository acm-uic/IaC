const assert = require('node:assert/strict');
const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');
const { test } = require('node:test');
const commentPlan = require('./comment_proxmox_plan.cjs');

function fixture(t, { hasChanges = true, comments = [] } = {}) {
  const directory = fs.mkdtempSync(path.join(os.tmpdir(), 'proxmox-plan-'));
  t.after(() => fs.rmSync(directory, { recursive: true }));
  const reportPath = path.join(directory, 'report.json');
  fs.writeFileSync(reportPath, JSON.stringify({
    has_changes: hasChanges,
    summary: hasChanges ? 'creates: 1; deletes: 0' : 'No resource creations or deletions are planned.',
  }));
  const calls = [];
  const github = {
    paginate: async (method, params) => {
      assert.equal(method, github.rest.issues.listComments);
      assert.equal(params.issue_number, 199);
      assert.equal(params.per_page, 100);
      return comments;
    },
    rest: { issues: {
      listComments() {},
      createComment: async params => calls.push({ method: 'create', ...params }),
      updateComment: async params => calls.push({ method: 'update', ...params }),
    } },
  };
  const context = {
    repo: { owner: 'acm-uic', repo: 'IaC' },
    payload: { pull_request: { number: 199, head: { sha: 'pr-head-sha' } } },
    runId: 123,
    serverUrl: 'https://github.com',
  };
  return { github, context, reportPath, stack: 'maid-cafe-k8s', calls };
}

function botComment(overrides = {}) {
  return { id: 42, user: { login: 'github-actions[bot]' },
    body: '<!-- opentofu-plan:maid-cafe-k8s -->\nOld plan', ...overrides };
}

test('creates a PR comment with the plan, head SHA and run link', async t => {
  const options = fixture(t);
  await commentPlan(options);
  assert.equal(options.calls.length, 1);
  assert.equal(options.calls[0].method, 'create');
  assert.equal(options.calls[0].issue_number, 199);
  assert.match(options.calls[0].body, /^<!-- opentofu-plan:maid-cafe-k8s -->/);
  assert.match(options.calls[0].body, /creates: 1; deletes: 0/);
  assert.match(options.calls[0].body, /pr-head-sha/);
  assert.match(options.calls[0].body, /https:\/\/github.com\/acm-uic\/IaC\/actions\/runs\/123/);
});

test('updates an existing bot comment instead of creating duplicates', async t => {
  const options = fixture(t, { comments: [botComment()] });
  await commentPlan(options);
  assert.equal(options.calls.length, 1);
  assert.equal(options.calls[0].method, 'update');
  assert.equal(options.calls[0].comment_id, 42);
});

test('does not post for a plan without creations or deletions', async t => {
  const options = fixture(t, { hasChanges: false });
  await commentPlan(options);
  assert.deepEqual(options.calls, []);
});

test('clears an outdated warning when the latest plan has no creations or deletions', async t => {
  const options = fixture(t, { hasChanges: false, comments: [botComment()] });
  await commentPlan(options);
  assert.equal(options.calls.length, 1);
  assert.equal(options.calls[0].method, 'update');
  assert.match(options.calls[0].body, /No resource creations or deletions are planned/);
});

test('does not edit human comments or another stack\'s bot comment', async t => {
  const options = fixture(t, { comments: [
    botComment({ user: { login: 'maintainer' } }),
    botComment({ body: '<!-- opentofu-plan:another-stack -->\nOld plan' }),
    botComment({ body: 'Quoted marker: <!-- opentofu-plan:maid-cafe-k8s -->' }),
  ] });
  await commentPlan(options);
  assert.equal(options.calls.length, 1);
  assert.equal(options.calls[0].method, 'create');
});

test('manual dispatch does not read a report or call the comments API', async () => {
  await commentPlan({ context: { payload: {} } });
});
