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
            enabled = False
            try:
                a.get('enabled')
                enabled = True
            except IndexError:
                if a.get('state', 'present') in ["present", "enabled"]:
                    enabled = True

            if enabled:
                enabled_activations.append(a.get('name'))

        return enabled_activations
