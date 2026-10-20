package ch.neatlovin.detox

import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterFragmentActivity

// FlutterFragmentActivity: required by the Health Connect permission screen.
class MainActivity : FlutterFragmentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        createNotificationChannel()
    }

    // Channel used by push notifications (id "detox", see AndroidManifest.xml).
    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val manager = getSystemService(NotificationManager::class.java) ?: return
        if (manager.getNotificationChannel(CHANNEL_ID) != null) return
        manager.createNotificationChannel(
            NotificationChannel(CHANNEL_ID, "Detox", NotificationManager.IMPORTANCE_HIGH).apply {
                description = "SOS de la communauté, soutiens et rappels"
            },
        )
    }

    private companion object {
        const val CHANNEL_ID = "detox"
    }
}
