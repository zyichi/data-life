package vip.datalife.apps.datalife;

import android.os.Bundle;
import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
  private static final String ACTION_CHANNEL = "android_app";
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);

    MethodChannel channel = new MethodChannel(getFlutterView(), ACTION_CHANNEL);
    channel.setMethodCallHandler((methodCall, result) -> {
      if (methodCall.method.equals("toBack")) {
        moveTaskToBack(false);
      }
    });
  }
}
