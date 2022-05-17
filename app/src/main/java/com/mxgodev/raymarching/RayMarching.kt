package com.mxgodev.raymarching

import android.opengl.GLES20
import android.opengl.GLES20.GL_COMPILE_STATUS
import android.opengl.GLES20.glGetShaderInfoLog
import android.util.Log
import java.nio.ByteBuffer
import java.nio.ByteOrder
import java.nio.FloatBuffer


class RayMarching(vertexShaderCode: String, fragmentShaderCode: String) {
    companion object {
        private const val COORDS_PER_VERTEX = 3
    }

    private val vertices = floatArrayOf(
        -1.0f, -1.0f, 0.0f,
        -1.0f, 1.0f, 0.0f,
        1.0f, -1.0f, 0.0f,
        1.0f, 1.0f, 0.0f,
    )

    private val vertexBuffer: FloatBuffer = ByteBuffer.allocateDirect(vertices.size * 4).run {
        order(ByteOrder.nativeOrder())
        asFloatBuffer().apply {
            put(vertices)
            position(0)
        }
    }

    private val program: Int

    private var uResolution: Int = 0
    private var uTime: Int = 0

    init {
        val vertexShader: Int = loadShader(GLES20.GL_VERTEX_SHADER, vertexShaderCode)
        val fragmentShader: Int = loadShader(GLES20.GL_FRAGMENT_SHADER, fragmentShaderCode)

        program = GLES20.glCreateProgram().also {
            GLES20.glAttachShader(it, vertexShader)
            GLES20.glAttachShader(it, fragmentShader)
            GLES20.glLinkProgram(it)
        }

        uResolution = GLES20.glGetUniformLocation(program, "u_resolution")
        uTime = GLES20.glGetUniformLocation(program, "u_time")
    }


    private fun loadShader(type: Int, shaderCode: String): Int {
        return GLES20.glCreateShader(type).also { shader ->
            GLES20.glShaderSource(shader, shaderCode)
            GLES20.glCompileShader(shader)
            val compiled = IntArray(1)
            GLES20.glGetShaderiv(shader, GL_COMPILE_STATUS, compiled, 0)
            if (compiled[0] == 0) {
                val log = glGetShaderInfoLog(shader)
                Log.e("SHADER", "Shader compilation error: ")
                Log.e("SHADER", log)
            }
        }
    }

    fun draw() {
        GLES20.glUseProgram(program)
        GLES20.glGetAttribLocation(program, "a_position").also {

            // Enable a handle to the triangle vertices
            GLES20.glEnableVertexAttribArray(it)

            // Prepare the triangle coordinate data
            GLES20.glVertexAttribPointer(
                it,
                COORDS_PER_VERTEX,
                GLES20.GL_FLOAT,
                false,
                COORDS_PER_VERTEX * 4,
                vertexBuffer
            )

            GLES20.glDrawArrays(GLES20.GL_TRIANGLE_STRIP, 0, vertices.size)

            GLES20.glDisableVertexAttribArray(it)
        }
    }

    fun setResolution(width: Float, height: Float) {
        GLES20.glUseProgram(program)
        GLES20.glUniform2fv(uResolution, 1, floatArrayOf(width, height), 0)
    }

    fun setTime(time: Float)  {
        GLES20.glUseProgram(program)
        GLES20.glUniform1f(uTime, time)
    }
}