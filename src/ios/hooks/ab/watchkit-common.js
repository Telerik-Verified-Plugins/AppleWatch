var fs = require('fs');

function addNativeTarget(pbxProject, prop) {
    var pbxNativeTargetSection = pbxProject.pbxNativeTargetSection(),
        nativeTargetGuid = pbxProject.generateUuid();

    console.log('Adding ' + prop.productName + ' Native Target');
    pbxNativeTargetSection[nativeTargetGuid] = { isa: 'PBXNativeTarget',
         buildConfigurationList: prop.buildConfiguration.uuid,
         buildConfigurationList_comment: 'Build configuration list for PBXNativeTarget ' + prop.productName,
         buildPhases: prop.buildPhases,
         buildRules: prop.buildRules,
         dependencies: prop.dependencies,
         name: prop.productName,
         productName: prop.productName,
         productReference: prop.productReference,
         productReference_comment: prop.productReference_comment,
         productType: prop.productType };

    pbxNativeTargetSection[nativeTargetGuid + '_comment'] = prop.productName;
    return nativeTargetGuid;
}

function replacePlaceholdersInPlist(plistPath, placeHolderValues) {
    var plistContents = fs.readFileSync(plistPath, 'utf8');
    for (var i = 0; i < placeHolderValues.length; i++) {
        var placeHolderValue = placeHolderValues[i],
            regexp = new RegExp(placeHolderValue.placeHolder, "g");
        plistContents = plistContents.replace(regexp, placeHolderValue.value);
    }
    fs.writeFileSync(plistPath, plistContents);
}

function quote(inputString) {
    return "\"" + inputString + "\"";
}

module.exports = {
    addNativeTarget : addNativeTarget,
    replacePlaceholdersInPlist : replacePlaceholdersInPlist,
    quoteString: quote
}
