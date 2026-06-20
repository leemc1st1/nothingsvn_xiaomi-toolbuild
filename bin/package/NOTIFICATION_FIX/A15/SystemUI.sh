work_dir=$(pwd)
source $work_dir/functions.sh
MAIN_FOLDER="$work_dir/build/baserom/images"
repS="python3 $work_dir/bin/strRep.py"
deviceTYPE=$(cat $work_dir/bin/ddevice/device_type.txt)
androidVER=$(cat $work_dir/bin/ddevice/androidver.txt)
rom_os=$(cat $work_dir/bin/ddevice/rom_os.txt)
APKEDITOR="java -jar $work_dir/bin/apktool/apke.jar"
repS="python3 $work_dir/bin/strRep.py"



if [[ $androidVER == "15" ]]; then
mods "Patching Notification Fix to SystemUI"
#ready for patch
mkdir -p $work_dir/apk_temp
isMiuiSystemUIDIR=$(find "$MAIN_FOLDER" -type d -name "MiuiSystemUI")
isMiuiSystemUI=$(find "$MAIN_FOLDER" -type f -name "MiuiSystemUI.apk")
$APKEDITOR d -t raw -f -no-dex-debug -i $isMiuiSystemUI -o $work_dir/apk_temp/isMiuiSystemUI.apk.out >/dev/null 2>&1
FOLDER="$work_dir/apk_temp/isMiuiSystemUI.apk.out"

patch_noti() {
  local smali_dir="$FOLDER"
  local class="
$smali_dir/classes*/com/android/systemui/qs/QSTileHost.smali
$smali_dir/classes*/com/android/systemui/statusbar/notification/interruption/MiuiNotificationInterruptStateProviderImpl.smali
$smali_dir/classes*/com/android/systemui/statusbar/notification/utils/NotificationUtil.smali
$smali_dir/classes*/com/android/systemui/MiuiOperatorCustomizedPolicy.smali
$smali_dir/classes*/com/miui/systemui/notification/MiuiBaseNotifUtil.smali
$smali_dir/classes*/com/miui/systemui/notification/NotificationSettingsManager.smali
$smali_dir/classes*/com/android/systemui/statusbar/policy/MiuiCarrierTextController.smali
$smali_dir/classes*/com/android/systemui/statusbar/pipeline/mobile/ui/viewmodel/MiuiCellularIconVM\$special\$\$inlined\$combine\$1\$3.smali
$smali_dir/classes*/com/android/systemui/statusbar/pipeline/mobile/ui/binder/MiuiMobileIconBinder\$bind\$1\$1\$10.smali
$smali_dir/classes*/com/android/systemui/statusbar/pipeline/mobile/ui/binder/MiuiMobileIconBinder\$bind\$1\$1.smali
"
  for i in $class; do
    [ -f "$i" ] || continue
    sed -i -E 's|(sget-boolean[[:space:]]+)([vp][0-9]+),[[:space:]]+Lmiui/os/Build;->IS_INTERNATIONAL_BUILD:Z|\1\2, Lmiui/os/xBuild;->IS_INTERNATIONAL_BUILD:Z|g' "$i"
    sed -i -E 's|(sget-boolean[[:space:]]+)([vp][0-9]+),[[:space:]]+Lcom/miui/utils/configs/MiuiConfigs;->IS_INTERNATIONAL_BUILD:Z|\1\2, Lmiui/os/xBuild;->IS_INTERNATIONAL_BUILD:Z|g' "$i"
  done
}

patch_noti

#Finishing
MiuiSystemUI=$(basename $isMiuiSystemUI)
$APKEDITOR b -f -i $work_dir/apk_temp/isMiuiSystemUI.apk.out -o $work_dir/apk_temp/final/$MiuiSystemUI >/dev/null 2>&1

if [ -f "$work_dir/apk_temp/final/$MiuiSystemUI" ]; then
    rm -rf $isMiuiSystemUIDIR/oat
	rm -rf $isMiuiSystemUIDIR/$MiuiSystemUI
    cp -rf $work_dir/apk_temp/final/$MiuiSystemUI $isMiuiSystemUIDIR
fi

rm -rf $work_dir/apk_temp
mods "Done"

fi