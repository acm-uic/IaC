import unittest

from check_proxmox_plan import check_plan


def resource(address, actions, before=None, after=None, importing=None, unknown=None):
    return {
        "address": address,
        "mode": "managed",
        "change": {
            "actions": actions,
            "before": before,
            "after": after,
            "importing": importing,
            "after_unknown": unknown or {},
        },
    }


class PlanSafetyTests(unittest.TestCase):
    def errors(self, *changes):
        return check_plan({"resource_changes": list(changes)})[0]

    def test_removed_resource_is_blocked_even_without_lifecycle_guard(self):
        self.assertTrue(self.errors(resource("proxmox_virtual_environment_vm.vm_101", ["delete"])))

    def test_creation_and_both_replacement_orders_are_blocked(self):
        for actions in (["create"], ["delete", "create"], ["create", "delete"]):
            with self.subTest(actions=actions):
                self.assertTrue(self.errors(resource("guest", actions)))

    def test_import_and_non_identity_update_are_allowed(self):
        self.assertFalse(self.errors(
            resource("guest", ["no-op"], importing={"id": "boba/101"}),
            resource("other", ["update"], {"vm_id": 102, "memory": 1024},
                     {"vm_id": 102, "memory": 2048}),
        ))

    def test_identity_placement_and_unknown_identity_changes_are_blocked(self):
        for field in ("id", "vm_id", "node_name", "vmid", "target_node"):
            with self.subTest(field=field):
                self.assertTrue(self.errors(resource("guest", ["update"], {field: "old"}, {field: "new"})))
                self.assertTrue(self.errors(resource("guest", ["update"], {field: "old"}, {}, unknown={field: True})))

    def test_forgetting_legacy_identity_requires_matching_adoption(self):
        stale = resource("proxmox_vm_qemu.k8s_01", ["forget"], {"id": "matcha/qemu/107"})
        adoption = resource("proxmox_virtual_environment_vm.vm_107", ["no-op"], importing={"id": "matcha/107"})
        self.assertTrue(self.errors(stale))
        self.assertFalse(self.errors(stale, adoption))
        wrong = resource("proxmox_virtual_environment_vm.vm_107", ["no-op"], importing={"id": "boba/107"})
        self.assertTrue(self.errors(stale, wrong))

    def test_other_state_removal_is_blocked(self):
        self.assertTrue(self.errors(resource("other", ["forget"], {"id": "matcha/qemu/107"})))

    def test_imported_container_id_metadata_must_match_actual_identity(self):
        imported = resource("ct", ["update"],
                            {"id": "100", "vm_id": None, "node_name": "boba"},
                            {"id": "100", "vm_id": 100, "node_name": "boba"},
                            importing={"id": "boba/100"})
        imported["type"] = "proxmox_virtual_environment_container"
        self.assertFalse(self.errors(imported))
        imported["change"]["after"]["vm_id"] = 101
        self.assertTrue(self.errors(imported))

    def test_unchanged_plan_is_allowed(self):
        self.assertFalse(self.errors())

    def test_reused_vmid_with_different_smbios_uuid_is_blocked(self):
        self.assertTrue(self.errors(resource("vm", ["update"],
                                            {"id": "107", "smbios": [{"uuid": "new-occupant"}]},
                                            {"id": "107", "smbios": [{"uuid": "old-occupant"}]})))


if __name__ == "__main__":
    unittest.main()
