import json

## todo: have pre-defined declarations for attributes

class UITestsConfigParser():
    def __init__(self, dictionary):
        for a, b in dictionary.items():
            if isinstance(b, (list, tuple)):
               setattr(self, a, [UITestsConfigParser(x) if isinstance(x, dict) else x for x in b])
            else:
               setattr(self, a, UITestsConfigParser(b) if isinstance(b, dict) else b)


with open("../Configuration/uitests_ios_config.json", mode='r') as f:
    config_uitests = json.load(f)
    config_uitests = UITestsConfigParser(config_uitests)


