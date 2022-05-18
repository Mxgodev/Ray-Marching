package com.mxgodev.raymarching

import android.content.Context
import android.opengl.GLSurfaceView
import android.view.MotionEvent

class OpenGLSurfaceView(context: Context) : GLSurfaceView(context) {
    private val renderer : OpenGLRenderer

    init {
        setEGLContextClientVersion(2)
        renderer = OpenGLRenderer(context)
        setRenderer(renderer)
    }
}