const fs = require('node:fs');

module.exports = async ({ github, context, reportPath, stack }) => {
  if (!context.payload.pull_request) return;

  const report = JSON.parse(fs.readFileSync(reportPath, 'utf8'));
  const marker = `<!-- opentofu-plan:${stack} -->`;
  const params = { ...context.repo, issue_number: context.payload.pull_request.number };
  const comments = await github.paginate(github.rest.issues.listComments, {
    ...params,
    per_page: 100,
  });
  const existing = comments.find(comment =>
    comment.user?.login === 'github-actions[bot]' && comment.body?.startsWith(marker)
  );

  // Do not create comments for update-only/no-op plans, but refresh any previous
  // warning so it cannot describe changes that are no longer in the plan.
  if (!report.has_changes && !existing) return;

  const runUrl = `${context.serverUrl}/${context.repo.owner}/${context.repo.repo}/actions/runs/${context.runId}`;
  const body = `${marker}\n## OpenTofu: ${stack}\n\n` +
    `PR head: \`${context.payload.pull_request.head.sha}\`\n\n` +
    `${report.summary}\n[Workflow run](${runUrl})`;
  if (existing) {
    await github.rest.issues.updateComment({
      ...context.repo,
      comment_id: existing.id,
      body,
    });
  } else {
    await github.rest.issues.createComment({ ...params, body });
  }
};
