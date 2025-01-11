#!/bin/bash
set +e

BASH_NAME="$0"
PRIVATE_KEY_SIZE=2048

while [[ $# -gt 0 ]]
do
  option="$1"

  case ${option} in
    --ca-chain)
    CA_CERTS_CHAIN="$2"
    shift # past argument
    shift # past value
    ;;
    --ca-certificate)
    CA_CERTIFICATE="$2"
    shift # past argument
    shift # past value
    ;;
    --ca-key)
    CA_KEY="$2"
    shift # past argument
    shift # past value
    ;;
    --common-name)
    COMMON_NAME="$2"
    shift # past argument
    shift # past value
    ;;
    --consul-uri)
    CONSUL_KV_BASE_PATH="$2"
    shift # past argument
    shift # past value
    ;;
    --dns)
    DNS="$2"
    shift # past argument
    shift # past value
    ;;
    --output-path)
    WORKING_DIRECTORY="$2"
    shift # past argument
    shift # past value
    ;;
    --valid-days)
    VALID_DAYS="$2"
    shift # past argument
    shift # past value
    ;;
    *)    # unknown option
    echo "Unknown option: $1."
    echo "This bash generates self-signed certificates from specified CA and saves to Consul backend."
    echo "Usage:"
    echo "${BASH_NAME} --ca-certificate [CA_CERTIFICATE] --ca-key [CA_KEY] --common-name [COMMON_NAME] --consul-uri [CONSUL_URI] --dns [DNS] --output-path [OUTPUT_PATH] --valid-days [VALID_DAYS]"
    exit 1
    ;;
  esac
done

if [[ ${CA_CERTS_CHAIN} = '' ]] || [[ ${CA_CERTIFICATE} = '' ]] || [[ ${CA_KEY} = '' ]] || [[ ${COMMON_NAME} = '' ]] || [[ ${CONSUL_KV_BASE_PATH} = '' ]] || [[ ${DNS} = '' ]] || [[ ${WORKING_DIRECTORY} = '' ]] || [[ ${VALID_DAYS} = '' ]]; then
  echo "Please specify all arguments"
  echo "This bash generates self-signed certificates from specified CA and saves to Consul backend."
  echo "Usage:"
  echo "${BASH_NAME} --ca-chain [CA_CERTS_CHAIN] --ca-certificate [CA_CERTIFICATE] --ca-key [CA_KEY] --common-name [COMMON_NAME] --consul-uri [CONSUL_URI] --dns [DNS] --output-path [OUTPUT_PATH] --valid-days [VALID_DAYS]"
  exit 1
fi

function get_consul_kv() {
  set +e
  local consul_key="$1"
  local timeout=10
  # Get value of ${consul_key}
  curl -k --connect-timeout ${timeout} ${consul_key}?raw=true
}

function put_consul_kv() {
  set +e
  local consul_key="$1"
  local data_file="$2"
  local timeout=10
  # Put data:${data_file} to ${consul_key}
  local result=`curl -k -X PUT --data-binary "@${data_file}" --connect-timeout ${timeout} ${consul_key}`
  if [[ ${result} == 'true' ]] ; then
    return 0
  else
    return 1
  fi
}

function generate_openssl_cnf() {
local output_path="$1"
local dns1="$2"
cat << EOF > ${output_path}/openssl.cnf
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name
[req_distinguished_name]
[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = ${dns1}
EOF
return $?
}

function isIssuedByCA() {
local certificate="$1";
local ca_certificate="$2"
openssl verify -verbose -CAfile ${ca_certificate} ${certificate}
return $?
}

function generateCertificateFromPrivateKey() {
  local working_directory="$1"
  local common_name="$2"
  local dns="$3"
  local ca_private_key="$4"
  local ca_certificate="$5"
  local private_key="$6"
  local valid_days="$7"
  local ca_certs_chain="$8"

  echo "Create openssl.cnf for ${common_name}"
  generate_openssl_cnf ${working_directory} ${dns}
  if [[ $? != 0 ]] ; then
    echo "Error generating ${common_name} openssl.cnf"
    return 1
  fi

  echo "Create csr for ${common_name}"
  openssl req -new -key ${private_key} -out ${working_directory}/ssl.csr -subj /CN=${common_name} -config ${working_directory}/openssl.cnf
  if [[ $? != 0 ]] ; then
    echo "Error generating ${common_name} csr"
    return 1
  fi

  echo "Create public certificate for ${common_name}"
  openssl x509 -req -in ${working_directory}/ssl.csr -CA ${ca_certificate} -CAkey ${ca_private_key} -CAcreateserial -out ${working_directory}/ssl.cert -days ${valid_days} -extensions v3_req -extfile ${working_directory}/openssl.cnf
  if [[ $? != 0 ]] ; then
    echo "Error generating ${common_name} public certificate"
    return 1
  fi

  echo "Create fullchain certificate for ${common_name}"
  cat ${working_directory}/ssl.cert ${ca_certs_chain} > ${working_directory}/sslchain.crt
  if [[ $? != 0 ]] ; then
    echo "Error generating ${common_name} fullchain certificate"
    return 1
  fi
  return 0
}

# Begin
echo "##############################################################################"
echo "Application ${COMMON_NAME} Certificates Generation - Begin"

if [[ ! -e ${WORKING_DIRECTORY} ]] ; then
  echo "Working directory ${WORKING_DIRECTORY} doesn't exists. Creating..."
  mkdir -p ${WORKING_DIRECTORY}
fi

echo "Get Consul key ${CONSUL_KV_BASE_PATH}/ssl_key"
ssl_key=$(get_consul_kv ${CONSUL_KV_BASE_PATH}/ssl_key)
echo "Get Consul key ${CONSUL_KV_BASE_PATH}/ssl_certificate"
ssl_certificate=$(get_consul_kv ${CONSUL_KV_BASE_PATH}/ssl_certificate)

if [[ ${ssl_key} != '' ]] ; then
  echo "Replace local ${COMMON_NAME} private key with the one from Consul"
  echo "${ssl_key}" > ${WORKING_DIRECTORY}/ssl.key

  if [[ ${ssl_certificate} != '' ]] ; then
    echo "Replace local ${COMMON_NAME} fullchain certificate with the one from Consul"
    echo "${ssl_certificate}" > ${WORKING_DIRECTORY}/ssl.crt

    isIssuedByCA ${WORKING_DIRECTORY}/ssl.crt ${CA_CERTIFICATE}
    if [[ $? != 0 ]] ; then
      echo "The current certificate is not issued by specified CA certificate ${CA_CERTIFICATE}, regenerating..."
      generateCertificateFromPrivateKey ${WORKING_DIRECTORY} ${COMMON_NAME} ${DNS} ${CA_KEY} ${CA_CERTIFICATE} ${WORKING_DIRECTORY}/ssl.key ${VALID_DAYS} ${CA_CERTS_CHAIN}
      if [[ $? != 0 ]] ; then
        echo "Error generating ${COMMON_NAME} certificate"
        echo "Application ${COMMON_NAME} Certificates Generation - End"
        echo "##############################################################################"
        exit 1
      fi

      echo "Put ${COMMON_NAME} certificate to ${CONSUL_KV_BASE_PATH}/ssl_certificate"
      put_consul_kv ${CONSUL_KV_BASE_PATH}/ssl_certificate ${WORKING_DIRECTORY}/ssl.cert
      if [[ $? != 0 ]] ; then
        echo "Error putting ${COMMON_NAME} certificate to Consul"
        echo "Application ${COMMON_NAME} Certificates Generation - End"
        echo "##############################################################################"
        exit 1
      fi
      echo "Put ${COMMON_NAME} certificate chain to ${CONSUL_KV_BASE_PATH}/ssl_certificate_chain"
      put_consul_kv ${CONSUL_KV_BASE_PATH}/ssl_certificate_chain ${WORKING_DIRECTORY}/sslchain.crt
      if [[ $? != 0 ]] ; then
        echo "Error putting ${COMMON_NAME} certificate chain to Consul"
        echo "Intermediate ${COMMON_NAME} Certificates chain Generation - End"
        echo "##############################################################################"
        exit 1
      fi
    fi
  else
    echo "No ${COMMON_NAME} certificate in Consul. Regenerating ${COMMON_NAME} certificate ${WORKING_DIRECTORY}/ssl.crt from private key..."
    generateCertificateFromPrivateKey ${WORKING_DIRECTORY} ${COMMON_NAME} ${DNS} ${CA_KEY} ${CA_CERTIFICATE} ${WORKING_DIRECTORY}/ssl.key ${VALID_DAYS} ${CA_CERTS_CHAIN}
    if [[ $? != 0 ]] ; then
      echo "Error generating ${COMMON_NAME} certificate"
      echo "Application ${COMMON_NAME} Certificates Generation - End"
      echo "##############################################################################"
      exit 1
    fi

    echo "Put ${COMMON_NAME} certificate to ${CONSUL_KV_BASE_PATH}/ssl_certificate"
    put_consul_kv ${CONSUL_KV_BASE_PATH}/ssl_certificate ${WORKING_DIRECTORY}/ssl.cert
    if [[ $? != 0 ]] ; then
      echo "Error putting ${COMMON_NAME} certificate to Consul"
      echo "Application ${COMMON_NAME} Certificates Generation - End"
      echo "##############################################################################"
      exit 1
    fi
    echo "Put ${COMMON_NAME} certificate chain to ${CONSUL_KV_BASE_PATH}/ssl_certificate_chain"
    put_consul_kv ${CONSUL_KV_BASE_PATH}/ssl_certificate_chain ${WORKING_DIRECTORY}/sslchain.crt
    if [[ $? != 0 ]] ; then
      echo "Error putting ${COMMON_NAME} certificate chain to Consul"
      echo "Intermediate ${COMMON_NAME} Certificates chain Generation - End"
      echo "##############################################################################"
      exit 1
    fi
  fi
else
    echo "Remove local private key and certificate..."
    rm -rf ${WORKING_DIRECTORY}/*

    echo "Create ${COMMON_NAME} private key"
    openssl genrsa -out ${WORKING_DIRECTORY}/ssl.key ${PRIVATE_KEY_SIZE}
    if [[ $? != 0 ]] ; then
      echo "Error generating ${COMMON_NAME} private key"
      echo "Application ${COMMON_NAME} Certificates Generation - End"
      echo "##############################################################################"
      exit 1
    fi

    generateCertificateFromPrivateKey ${WORKING_DIRECTORY} ${COMMON_NAME} ${DNS} ${CA_KEY} ${CA_CERTIFICATE} ${WORKING_DIRECTORY}/ssl.key ${VALID_DAYS} ${CA_CERTS_CHAIN}
    if [[ $? != 0 ]] ; then
      echo "Error generating ${COMMON_NAME} certificate"
      echo "Application ${COMMON_NAME} Certificates Generation - End"
      echo "##############################################################################"
      exit 1
    fi

    echo "Put ${COMMON_NAME} private key to ${CONSUL_KV_BASE_PATH}/ssl_key"
    put_consul_kv ${CONSUL_KV_BASE_PATH}/ssl_key ${WORKING_DIRECTORY}/ssl.key
    if [[ $? != 0 ]] ; then
      echo "Error saving ${COMMON_NAME} private key."
      echo "Application ${COMMON_NAME} Certificates Generation - End"
      echo "##############################################################################"
      exit 1
    fi
    echo "Put ${COMMON_NAME} certificate to ${CONSUL_KV_BASE_PATH}/ssl_certificate"
    put_consul_kv ${CONSUL_KV_BASE_PATH}/ssl_certificate ${WORKING_DIRECTORY}/ssl.cert
    if [[ $? != 0 ]] ; then
      echo "Error saving ${COMMON_NAME} certificate."
      echo "Application ${COMMON_NAME} Certificates Generation - End"
      echo "##############################################################################"
      exit 1
    fi
    echo "Put ${COMMON_NAME} certificate chain to ${CONSUL_KV_BASE_PATH}/ssl_certificate_chain"
    put_consul_kv ${CONSUL_KV_BASE_PATH}/ssl_certificate_chain ${WORKING_DIRECTORY}/sslchain.crt
    if [[ $? != 0 ]] ; then
      echo "Error putting ${COMMON_NAME} certificate chain to Consul"
      echo "Intermediate ${COMMON_NAME} Certificates chain Generation - End"
      echo "##############################################################################"
      exit 1
    fi

  fi

echo "Application ${COMMON_NAME} Certificates Generation - End"
echo "##############################################################################"