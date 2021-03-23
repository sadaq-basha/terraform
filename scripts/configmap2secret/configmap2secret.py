# python3 configmap2secrets.py ../../kube/config/dev/internal-resources-cm.yml 
import base64
from pathlib import Path
import sys
import ruamel.yaml
from ruamel.yaml.comments import CommentedMap as OrderedDict  # to avoid '!!omap' in yaml

input_file = Path(sys.argv[1])

yaml = ruamel.yaml.YAML()
yaml.compact(seq_seq=False, seq_map=True)
yaml.default_flow_style = False
yaml.explicit_start = True
yaml.preserve_quotes = True
yaml.indent(mapping=2, sequence=2, offset=0)
yaml.version = (1, 2)

L = [D for D in yaml.load_all(input_file)]

for D in L:
    if D.get('kind') == 'ConfigMap':
        OD = OrderedDict()
        for k, v in D.get('data').items():
            OD[k] = base64.b64encode(v.encode('ascii')).decode('ascii')
    
        D['kind'] = 'Secret'
        D['data'] = OD
    
yaml.dump_all(L, stream=sys.stdout)
