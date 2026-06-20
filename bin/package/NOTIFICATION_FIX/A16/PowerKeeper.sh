work_dir=$(pwd)
source $work_dir/functions.sh
MAIN_FOLDER="$work_dir/build/baserom/images"
repS="python3 $work_dir/bin/strRep.py"
deviceTYPE=$(cat $work_dir/bin/ddevice/device_type.txt)
APKEDITOR="java -jar $work_dir/bin/apktool/apke.jar"
repS="python3 $work_dir/bin/strRep.py"


patch "Patching PowerKeeper"
#ready for patch
mkdir -p $work_dir/apk_temp
isPowerKeeperDIR=$(find "$MAIN_FOLDER" -type d -name "PowerKeeper")
isPowerKeeper=$(find "$MAIN_FOLDER" -type f -name "PowerKeeper.apk")
$APKEDITOR d -t raw -f -no-dex-debug -i $isPowerKeeper -o $work_dir/apk_temp/isPowerKeeper.apk.out >/dev/null 2>&1
FOLDER="$work_dir/apk_temp/isPowerKeeper.apk.out"

fix_noti() {
  local smali_dir="$FOLDER"
  local class="
$smali_dir/classes*/com/miui/powerkeeper/batterylife/BatteryLifeChecker.smali
$smali_dir/classes*/com/miui/powerkeeper/batterylife/ProcCpuinfoManager.smali
$smali_dir/classes*/com/miui/powerkeeper/batterylife/ProcCpuTimeInStateManager.smali
$smali_dir/classes*/com/miui/powerkeeper/batterylife/ProcScreenPowerManager.smali
$smali_dir/classes*/com/miui/powerkeeper/cloudcontrol/CloudUpdateHideMode.smali
$smali_dir/classes*/com/miui/powerkeeper/cloudcontrol/CloudUpdateReceiver.smali
$smali_dir/classes*/com/miui/powerkeeper/cloudcontrol/LocalUpdateUtils.smali
$smali_dir/classes*/com/miui/powerkeeper/controller/DeviceIdleController\$1.smali
$smali_dir/classes*/com/miui/powerkeeper/controller/DeviceIdleController\$2.smali
$smali_dir/classes*/com/miui/powerkeeper/customerpower/CustomerPowerCheck.smali
$smali_dir/classes*/com/miui/powerkeeper/dfs/UsageAppTracker.smali
$smali_dir/classes*/com/miui/powerkeeper/feedbackcontrol/ThermalLogUploader.smali
$smali_dir/classes*/com/miui/powerkeeper/feedbackcontrol/ThermalManager.smali
$smali_dir/classes*/com/miui/powerkeeper/millet/MilletConfig.smali
$smali_dir/classes*/com/miui/powerkeeper/perfengine/PeGameController.smali
$smali_dir/classes*/com/miui/powerkeeper/powerchecker/PowerCheckerCloudPolicy.smali
$smali_dir/classes*/com/miui/powerkeeper/statemachine/DebugLabelSetting.smali
$smali_dir/classes*/com/miui/powerkeeper/statemachine/DisplayFrameSetting.smali
$smali_dir/classes*/com/miui/powerkeeper/statemachine/PadSleepModeController.smali
$smali_dir/classes*/com/miui/powerkeeper/statemachine/PadSleepModeController\$SleepHandler.smali
$smali_dir/classes*/com/miui/powerkeeper/statemachine/PhoneSleepModeController.smali
$smali_dir/classes*/com/miui/powerkeeper/statemachine/PhoneSleepModeController\$SleepHandler.smali
$smali_dir/classes*/com/miui/powerkeeper/statemachine/ThermalIECHandler.smali
$smali_dir/classes*/com/miui/powerkeeper/thermalcollector/event/BaseEvent.smali
$smali_dir/classes*/com/miui/powerkeeper/tracker/TrackerManager\$PrivacyPolicy.smali
$smali_dir/classes*/com/miui/powerkeeper/unionpower/powerseg/PSUtils.smali
$smali_dir/classes*/com/miui/powerkeeper/unionpower/utils/UnionPowerConfig.smali
$smali_dir/classes*/com/miui/powerkeeper/utils/ExtraVideoScenarioUtils.smali
$smali_dir/classes*/com/miui/powerkeeper/utils/GmsObserver.smali
$smali_dir/classes*/com/miui/powerkeeper/utils/Utils.smali
$smali_dir/classes*/com/miui/powerkeeper/PowerKeeperApplication.smali
$smali_dir/classes*/com/ot/pubsub/util/m.smali
$smali_dir/classes*/com/xiaomi/channel/commonutils/android/MIUIUtils.smali
$smali_dir/classes*/com/xiaomi/channel/commonutils/network/Network.smali
$smali_dir/classes*/com/xiaomi/onetrack/util/DeviceUtil.smali
$smali_dir/classes*/com/xiaomi/onetrack/util/q.smali
$smali_dir/classes*/com/xiaomi/onetrack/util/x.smali
$smali_dir/classes*/com/xiaomi/push/service/XMPushService.smali
$smali_dir/classes*/e/e.smali
$smali_dir/classes*/f/c.smali
$smali_dir/classes*/miui/payment/PaymentManager.smali
$smali_dir/classes*/miui/provider/ExtraNetwork.smali
$smali_dir/classes*/miui/theme/ThemeManagerHelper.smali
$smali_dir/classes*/miui/yellowpage/HostManager.smali
$smali_dir/classes*/miui/yellowpage/YellowPageUtils.smali
$smali_dir/classes*/q/o.smali
$smali_dir/classes*/x/j.smali
$smali_dir/classes*/o/d.smali
$smali_dir/classes*/v/j.smali
"
  for i in $class; do
    [ -f "$i" ] || continue
    sed -i -E 's|(sget-boolean[[:space:]]+)([vp][0-9]+),[[:space:]]+Lmiui/os/Build;->IS_INTERNATIONAL_BUILD:Z|\1\2, Lmiui/os/xBuild;->IS_INTERNATIONAL_BUILD:Z|g' "$i"
  done
}

fix_noti

#Finishing
PowerKeeper=$(basename $isPowerKeeper)
$APKEDITOR b -f -i $work_dir/apk_temp/isPowerKeeper.apk.out -o $work_dir/apk_temp/final/$PowerKeeper >/dev/null 2>&1

if [ -f "$work_dir/apk_temp/final/$PowerKeeper" ]; then
    rm -rf $isPowerKeeperDIR/*
    cp -rf $work_dir/apk_temp/final/$PowerKeeper $isPowerKeeperDIR
fi

rm -rf $work_dir/apk_temp
patch "Done"