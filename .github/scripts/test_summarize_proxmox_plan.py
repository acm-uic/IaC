import contextlib
import io
import json
import tempfile
import unittest
from pathlib import Path

from summarize_proxmox_plan import main, summarize_plan


def resource(address, actions, **change):
    return {"address": address, "change": {"actions": actions, **change}}


class PlanSummaryTests(unittest.TestCase):
    def test_creations_deletions_and_both_replacement_orders_are_reported(self):
        report = summarize_plan({"resource_changes": [
            resource("proxmox_virtual_environment_vm.k8s_05", ["create"]),
            resource("container.old", ["delete"]),
            resource("vm.replace_destroy_first", ["delete", "create"]),
            resource("vm.replace_create_first", ["create", "delete"]),
        ]})
        self.assertTrue(report["has_changes"])
        self.assertIn("creates: 3; deletes: 3", report["summary"])
        self.assertIn("| `proxmox_virtual_environment_vm.k8s_05` | create |", report["summary"])
        self.assertIn("| `container.old` | delete |", report["summary"])
        self.assertEqual(report["summary"].count("| replace |"), 2)

    def test_identity_updates_imports_and_forgetting_state_do_not_fail_or_trigger_comments(self):
        report = summarize_plan({"resource_changes": [
            resource("vm.changed", ["update"], before={"vm_id": 107, "node_name": "old"},
                     after={"vm_id": 242, "node_name": "new"}),
            resource("legacy", ["forget"]),
            resource("imported", ["no-op"], importing={"id": "boba/101"}),
        ]})
        self.assertFalse(report["has_changes"])
        self.assertIn("Imports: 1; creates: 0; deletes: 0; updates: 1; forgets: 1; unchanged: 1", report["summary"])

    def test_empty_plan_and_data_sources_do_not_trigger_comments(self):
        self.assertFalse(summarize_plan({})["has_changes"])
        data = resource("data.remote", ["read"])
        data["mode"] = "data"
        self.assertFalse(summarize_plan({"resource_changes": [data]})["has_changes"])

    def test_summary_never_publishes_values_outputs_or_provider_configuration(self):
        plan = {"resource_changes": [
            resource("vm.secret", ["delete"], before={"password": "private-value"},
                     before_sensitive={"password": True}),
        ], "output_changes": {"token": "private-output"}, "configuration": "private-provider"}
        report = summarize_plan(plan)
        self.assertIn("vm.secret", report["summary"])
        for value in ("private-value", "private-output", "private-provider", "password"):
            self.assertNotIn(value, json.dumps(report))

    def test_resource_addresses_cannot_break_markdown_table_or_insert_html(self):
        report = summarize_plan({"resource_changes": [resource('vm["`|\n<b>"]', ["create"])]})
        self.assertIn("&#96;&#124; &lt;b&gt;", report["summary"])

    def test_large_plans_are_truncated_but_keep_full_counts(self):
        report = summarize_plan({"resource_changes": [
            resource(f"vm.guest_{index}", ["create"]) for index in range(3000)
        ]})
        self.assertTrue(report["has_changes"])
        self.assertIn("creates: 3000", report["summary"])
        self.assertIn("additional resources omitted", report["summary"])
        self.assertLess(len(report["summary"]), 51000)

    def test_cli_succeeds_for_any_action_and_writes_sanitized_report(self):
        with tempfile.TemporaryDirectory() as directory:
            plan_path = Path(directory) / "plan.json"
            report_path = Path(directory) / "report.json"
            for actions in (["create"], ["delete"], ["delete", "create"], ["update"], ["forget"]):
                with self.subTest(actions=actions):
                    plan_path.write_text(json.dumps({"resource_changes": [
                        resource("vm.any", actions, before={"token": "secret"}),
                    ]}), encoding="utf-8")
                    stdout = io.StringIO()
                    with contextlib.redirect_stdout(stdout):
                        self.assertEqual(main([str(plan_path), "--report", str(report_path)]), 0)
                    report = json.loads(report_path.read_text(encoding="utf-8"))
                    self.assertEqual(stdout.getvalue(), report["summary"])
                    self.assertNotIn("secret", report_path.read_text(encoding="utf-8"))


if __name__ == "__main__":
    unittest.main()
