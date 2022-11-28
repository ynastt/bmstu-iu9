import glfw
from OpenGL.GL import *
import math
import numpy

x_angle = 0
y_angle = 0
scale = 0.3
scaleX = 0.3
scaleY = 0.3
accuracy = 0
a = 0.5
b = 0.7
point_array = []
color_array = []
flying_speed = 0
V = 0.0009
acl = 0.00006


def make_vertices(x, y, z):
    global point_array, color_array, accuracy, a, b
    point_array = []
    color_array = []
    accuracy = 0
    color = [0.0, 0.5, 0.4]
    t = 0
    while t < 2.2 * math.pi:
        k = -1.5
        while k < 1.6:
            x = a * math.cos(t)
            z = b * math.sin(t)
            y = k * k
            new_point = [x, y, z]
            point_array.append(new_point)
            color_array.append(color)
            accuracy += 1
            k += 0.1
        t += 0.1


def create_shader(shader_type, source):
    shader = glCreateShader(shader_type)
    glShaderSource(shader, source)
    glCompileShader(shader)
    return shader


def main():
    if not glfw.init():
        return
    window = glfw.create_window(800, 800, "Lab8", None, None)
    if not window:
        glfw.terminate()
        return
    glfw.make_context_current(window)
    glfw.set_key_callback(window, callback)

    vertex = create_shader(GL_VERTEX_SHADER, """
    varying vec4 vertex_color;
                void main(){
                    gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
                    vertex_color = gl_Color;
                }""")
    fragment = create_shader(GL_FRAGMENT_SHADER, """
    varying vec4 vertex_color;
                void main() {
                    gl_FragColor = vertex_color;
    }""")
    program = glCreateProgram()
    glAttachShader(program, vertex)
    glAttachShader(program, fragment)
    glLinkProgram(program)
    make_vertices(0.0, -5, 0.0)
    glScalef(0.3, 0.3, 0.3)
    # print(point_array)
    glUseProgram(program)
    while glfw.get_key(window, glfw.KEY_ESCAPE) != glfw.PRESS and not glfw.window_should_close(window):
        display(window)
        glfw.swap_buffers(window)
        glfw.poll_events()
    glfw.destroy_window(window)
    glfw.terminate()


def callback(window, key, scancode, action, mods):
    global x_angle, y_angle, scale, scaleX, scaleY
    if key == glfw.KEY_A:
        y_angle -= 2
    if key == glfw.KEY_D:
        y_angle += 2
    if key == glfw.KEY_W:
        x_angle -= 2
    if key == glfw.KEY_S:
        x_angle += 2
    if key == glfw.KEY_UP:
        scale += 0.05
    if key == glfw.KEY_DOWN:
        scale -= 0.05
    if key == glfw.KEY_X:
        scaleX += 0.05
    if key == glfw.KEY_Y:
        scaleY += 0.05
    if key == glfw.KEY_LEFT:
        scaleX -= 0.05
    if key == glfw.KEY_RIGHT:
        scaleY -= 0.05


def display(window):
    glClearColor(0.2, 0.2, 0.2, 1.0)
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
    glEnableClientState(GL_VERTEX_ARRAY)
    glEnableClientState(GL_COLOR_ARRAY)
    glVertexPointer(3, GL_FLOAT, 0, point_array)
    glColorPointer(3, GL_FLOAT, 0, color_array)
    glDrawArrays(GL_LINE_STRIP, 0, accuracy)
    glDisableClientState(GL_VERTEX_ARRAY)
    glDisableClientState(GL_COLOR_ARRAY)
    glLoadIdentity()
    glScalef(scale, scale, scale)
    glScalef(4, 4, 4)
    glScalef(scaleX, scaleY, scale)
    glRotatef(x_angle, 1.0, 0, 0)
    glRotatef(y_angle, 0, 1.0, 0)
    draw_axis()
    draw_wall()
    glLineWidth(1.0)
    glPushMatrix()
    glPopMatrix()
    move_object()


def move_object():
    global V, flying_speed, acl
    glTranslatef(0, flying_speed, 0)
    flying_speed -= V
    V += acl
    if flying_speed < - 1 or flying_speed > 0:
        V = -V


def draw_axis():
    glLineWidth(1.0)
    glBegin(GL_LINES)
    glColor4f(1.0, 0.0, 0.0, 1.0)  # x - red
    glVertex3f(1.0, 0.0, 0.0)
    glVertex3f(0.0, 0.0, 0.0)
    glColor4f(0.0, 0.5, 0.0, 1.0)  # y - green
    glVertex3f(0.0, 1.0, 0.0)
    glVertex3f(0.0, 0.0, 0.0)
    glColor4f(0.0, 0.0, 1.0, 1.0)  # z - blue
    glVertex3f(0.0, 0.0, 1.0)
    glVertex3f(0.0, 0.0, 0.0)
    glEnd()


def draw_wall():
    glLineWidth(5.0)
    glBegin(GL_LINES)
    glColor4f(1.0, 0.0, 0.0, 1.0)  # x - red
    glVertex3f(1.0, 2.28, 0.0)
    glVertex3f(-1.0, 2.28, 0.0)
    glEnd()
    glBegin(GL_LINES)
    glColor4f(1.0, 0.0, 0.0, 1.0)  # x - red
    glVertex3f(1.0, -1.0, 0.0)
    glVertex3f(-1.0, -1.0, 0.0)
    glEnd()


if __name__ == '__main__':
    main()
