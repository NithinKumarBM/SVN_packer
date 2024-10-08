#Set AWS CA_BUNDLE
export AWS_CA_BUNDLE=/etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem
#Add REQUESTS_CA_BUNDLE
export REQUESTS_CA_BUNDLE=/etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem
#Add Python default venv bin dir to PATH
if [[ ":$PATH:" != *":/opt/conda/envs/python-default/bin"* ]]; then
    export PATH="$PATH:/opt/conda/envs/python-default/bin"
fi
if [[ ":$PATH:" != *":/opt/conda/envs/python2-default/bin"* ]]; then
    export PATH="$PATH:/opt/conda/envs/python2-default/bin"
fi
#Set pip default timeout to 5 minutes
export PIP_DEFAULT_TIMEOUT=300