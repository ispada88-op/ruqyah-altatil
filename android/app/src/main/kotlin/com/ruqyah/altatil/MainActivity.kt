package com.ruqyah.altatil

import android.hardware.GeomagneticField
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

// يجب أن ترث من AudioServiceActivity حتى يعمل just_audio_background
// (التشغيل في الخلفية + إشعار التحكم + ربط الـ AudioHandler).
class MainActivity : AudioServiceActivity() {
    // الانحراف المغناطيسي (شرقاً موجب) لبوصلة القبلة: نموذج المجال المدمج في
    // أندرويد، بلا إنترنت. بوصلة flutter_compass على أندرويد تعطي الشمال
    // المغناطيسي، والقبلة تُحسب من الشمال الحقيقي.
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.ruqyah.altatil/declination")
            .setMethodCallHandler { call, result ->
                if (call.method == "get") {
                    val lat = call.argument<Double>("lat")
                    val lon = call.argument<Double>("lon")
                    if (lat == null || lon == null) {
                        result.error("bad_args", "lat/lon required", null)
                    } else {
                        val field = GeomagneticField(
                            lat.toFloat(), lon.toFloat(), 0f, System.currentTimeMillis()
                        )
                        result.success(field.declination.toDouble())
                    }
                } else {
                    result.notImplemented()
                }
            }
    }
}
