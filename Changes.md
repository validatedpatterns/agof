# Change history for releases

## Changes for v2 (initially released November 2024)

* Drop undocumented "extra" features in code derived from ansible-workshops (i.e. `build_idm`, `build_sat`).
* Drop rpm-based installation scheme (hosts/ subdirectory).
* Drop "legacy" Makefile targets (they were for the non-containerized install)
* Drop support for AAP versions <= 2.4. This includes dropping support for mechanisms other than containerized install.
* Support for AAP 2.5
* Introduce direct support for running under OpenShift Validated Patterns
* Depend on infra.aap_utilities to handle some installation related work
* Add mechanism to disable eda_rulebook_activations prior to configuring them to prevent crash of aap configuration
  playbook while trying to manage running rulebook activations
