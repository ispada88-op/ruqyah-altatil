package com.ruqyah.altatil

import com.ryanheise.audioservice.AudioServiceActivity

// يجب أن ترث من AudioServiceActivity حتى يعمل just_audio_background
// (التشغيل في الخلفية + إشعار التحكم + ربط الـ AudioHandler).
class MainActivity : AudioServiceActivity()
