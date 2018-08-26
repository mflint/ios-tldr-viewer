#1/usr/bin/env sh
secretsFile=$PROJECT_DIR/scripts/fabric.secrets
if [ ! -f $secretsFile ]; then
    echo "warning: '$secretsFile' not found"
    exit 0
fi

apiKey=$(sed -n '1p' < $secretsFile)
secretKey=$(sed -n '2p' < $secretsFile)

/usr/libexec/PlistBuddy -c "Set :Fabric:APIKey $apiKey" $PRODUCT_SETTINGS_PATH

$PROJECT_DIR/Fabric.framework/run $apiKey $secretKey
