#!/usr/bin/env bash

DERIVED_PATH=${SOURCE_ROOT}/Simplenote/DerivedSources
SCRIPT_PATH=${SOURCE_ROOT}/Scripts/build-phases/replace_secrets.rb

CREDS_INPUT_PATH=${SOURCE_ROOT}/Simplenote/Credentials/SPCredentials.tpl
CREDS_OUTPUT_PATH=${DERIVED_PATH}/SPCredentials.swift

CREDS_TEMPLATE_PATH=${SOURCE_ROOT}/Simplenote/Credentials/Templates/SPCredentials-Template.swift

## Validate Secrets!
##
if [ ! -f $SECRETS_PATH ]; then

    echo ">> Using Templated Secrets"

    ## Generate the Derived Folder. If needed
    ##
    mkdir -p ${DERIVED_PATH}

    ## Create a credentials file from the template (if needed)
    ## then copy it into place for the build.
    ##
    if [ ! -f $CREDS_OUTPUT_PATH ]; then
        echo ">> Creating Credentials File from Template: ${CREDS_FILE_PATH}"
        cp ${CREDS_TEMPLATE_PATH} ${CREDS_OUTPUT_PATH}
    fi

else

    echo ">> Loading Secrets ${SECRETS_PATH}"

    ## Generate the Derived Folder. If needed
    ##
    mkdir -p ${DERIVED_PATH}

    ## Generate ApiCredentials.swift
    ##
    echo ">> Generating Credentials ${CREDS_OUTPUT_PATH}"
    ruby ${SCRIPT_PATH} -i ${CREDS_INPUT_PATH} -s ${SECRETS_PATH} > ${CREDS_OUTPUT_PATH}

fi
