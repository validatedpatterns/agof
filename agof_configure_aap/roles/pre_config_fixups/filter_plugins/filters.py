class FilterModule(object):
    def filters(self):
        return {
            'activations_to_enable': self.activations_to_enable,
        }

    def activations_to_enable(self, activations=None):
        enabled_activations = []

        # Early out without argument
        if activations is None:
            return enabled_activations

        for a in activations:
            if 'enabled' in a:
                enabled = bool(a['enabled'])
            elif a.get('state', 'present') in ["present", "enabled"]:
                enabled = True
            else:
                enabled = False

            if enabled:
                enabled_activations.append(a.get('name'))

        return enabled_activations
