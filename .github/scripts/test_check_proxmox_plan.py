import unittest

from check_proxmox_plan import K8S_01_IDENTITY, check_plan


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

    def new_k8s(self):
        guest = resource("proxmox_virtual_environment_vm.k8s_01", ["create"],
                         after=dict(K8S_01_IDENTITY))
        guest["type"] = "proxmox_virtual_environment_vm"
        return guest

    def test_only_the_reviewed_new_k8s_vm_is_allowed(self):
        self.assertFalse(self.errors(self.new_k8s()))
        self.assertTrue(self.errors(self.new_k8s(), resource("other", ["create"])))
        for field, value in (("address", "proxmox_vm_qemu.k8s_01"),
                             ("type", "proxmox_virtual_environment_container")):
            with self.subTest(field=field):
                guest = self.new_k8s()
                guest[field] = value
                self.assertTrue(self.errors(guest))

    def test_new_k8s_identity_and_stopped_state_must_be_known_and_match(self):
        for field, value in (("vm_id", 107), ("node_name", "matcha"),
                             ("name", "taskbox-template"), ("started", True),
                             ("template", True), ("protection", False)):
            with self.subTest(field=field):
                guest = self.new_k8s()
                guest["change"]["after"][field] = value
                self.assertTrue(self.errors(guest))
                guest = self.new_k8s()
                guest["change"]["after_unknown"][field] = True
                self.assertTrue(self.errors(guest))

    def test_new_k8s_exception_never_allows_deletion_or_replacement(self):
        for actions in (["delete"], ["delete", "create"], ["create", "delete"]):
            with self.subTest(actions=actions):
                guest = self.new_k8s()
                guest["change"]["actions"] = actions
                self.assertTrue(self.errors(guest))

    def test_new_k8s_exception_never_adopts_or_reuses_existing_state(self):
        for field, value in (("before", {"id": "107"}),
                             ("importing", {"id": "matcha/107"})):
            with self.subTest(field=field):
                guest = self.new_k8s()
                guest["change"][field] = value
                self.assertTrue(self.errors(guest))

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
