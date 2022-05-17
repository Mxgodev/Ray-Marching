package com.mxgodev.raymarching

import android.content.Context
import android.opengl.GLES20
import android.opengl.GLSurfaceView
import android.opengl.Matrix
import android.os.SystemClock
import android.util.Log
import java.io.BufferedReader
import java.nio.ByteBuffer
import java.nio.ByteOrder
import java.nio.FloatBuffer
import javax.microedition.khronos.egl.EGLConfig
import javax.microedition.khronos.opengles.GL10

class OpenGLRenderer(private val context: Context) : GLSurfaceView.Renderer {
    private val vPMatrix = FloatArray(16)
    private val projectionMatrix = FloatArray(16)
    private val viewMatrix = FloatArray(16)

    private lateinit var rayMarching: RayMarching

    override fun onSurfaceCreated(p0: GL10?, p1: EGLConfig?) {
        GLES20.glClearColor(0.0f, 0.0f, 0.0f, 1.0f)

        val vertexShaderCode = readShaderCode(R.raw.vertex)
        val fragmentShaderCode = readShaderCode(R.raw.fragment)

        rayMarching = RayMarching(vertexShaderCode, fragmentShaderCode)
    }

    override fun onSurfaceChanged(p0: GL10?, width: Int, height: Int) {
        GLES20.glViewport(0, 0, width, height)
        rayMarching.setResolution(width.toFloat(), height.toFloat())
    }

    override fun onDrawFrame(p0: GL10?) {
        GLES20.glClear(GLES20.GL_COLOR_BUFFER_BIT)
        val time = SystemClock.uptimeMillis() / 1000.0f
        rayMarching.setTime(time)
        rayMarching.draw()
    }

    private fun readShaderCode(resourceId: Int): String {
        val stream = context.resources.openRawResource(resourceId)
        return stream.bufferedReader().use(BufferedReader::readText)
    }
}