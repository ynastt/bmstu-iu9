# Лабораторная работа №5 – алгоритмы отсечения
# а. Реализовать алгоритм отсечения .ВейлераАзертона:разность
# (для произвольных многоугольников). Размерность пространства: Двумерное
# б. Ввод исходных данных каждого из алгоритмов производится интерактивно с помощью
# клавиатуры и/или мыши

from pyglet import *
from pyglet.gl import *
from pyglet.window import key, mouse, Window
import llist as llist

window = Window(800, 800, resizable=False, caption='Lab 5')


class Point(object):

    def __init__(self, x, y):
        self.x = x
        self.y = y

    def get_coord(self):
        return self.x, self.y

    def __sub__(self, other):
        return Point(other.x-self.x, other.y-self.y)

    def __eq__(self, other):
        return (self.x, self.y) == (other.x, other.y)

    def __hash__(self):
        return hash((self.x, self.y))


# extensions of  double-linked list #
def find(dllist, value):
    if isinstance(dllist, llist.dllist):
        for i in range(len(dllist)):
            if dllist[i] == value:
                return dllist[i]
        return None
    else:
        raise TypeError("First argument must have type 'llist.dllist'")


def find_node(dllist, value):
    if isinstance(dllist, llist.dllist):
        for i in range(len(dllist)):
            if dllist[i] == value:
                return dllist.nodeat(i)
        return None
    else:
        raise TypeError("First argument must have type 'llist.dllist'")


def bool_find(dllist, value):
    return not (isinstance(find(dllist, value), type(None)))


def contains(dllist, node):
    if isinstance(dllist, llist.dllist) and isinstance(node, llist.dllistnode):
        for i in range(len(dllist)):
            if dllist[i] == node.value:
                return dllist.nodeat(i)
        return None
    elif isinstance(node, llist.dllistnode):
        raise TypeError("First argument must have type 'llist.dllist'")
    else:
        raise ValueError("Second argument must have type 'llist.dllistnode'")


def bool_contains(dllist, node):
    return contains(dllist, node) is not None


def next(dllist, node):
    if isinstance(dllist, llist.dllist) and isinstance(node, llist.dllistnode):
        if node.next is not None:
            return node.next
        else:
            return dllist.first
    elif isinstance(node, llist.dllistnode):
        raise TypeError("First argument must have type 'llist.dllist'")
    else:
        raise ValueError("Second argument must have type 'llist.dllistnode'")


def prev(dllist, node):
    if isinstance(dllist, llist.dllist) and isinstance(node, llist.dllistnode):
        if node.prev is not None:
            return node.prev
        else:
            return dllist.last
    elif isinstance(node, llist.dllistnode):
        raise TypeError("First argument must have type 'llist.dllist'")
    else:
        raise ValueError("Second argument must have type 'llist.dllistnode'")


def deepcopy(dllist):
    copy_dllist = llist.dllist()
    this = dllist.first
    while this is not None:
        copy_dllist.insert(this.value)
        this = this.next
    return copy_dllist


def delete(dllist, value):
    if len(dllist) > 0 and isinstance(find(dllist, value), Point):
        node = llist.dllistnode(value)
        node_find = contains(dllist, node)
        dllist.remove(node_find)
    else:
        raise ValueError("Element not found!")


# x = x0 + a * t
# y = y0 + b * t
class LineParam(object):

    def __init__(self, p1, p2):
        self.a = p2.x - p1.x
        self.b = p2.y - p1.y
        self.x0 = p1.x
        self.y0 = p1.y

    def get_point(self, t):
        x = self.x0 + self.a * t
        y = self.y0 + self.b * t
        return Point(int(x), int(y))

    def intersect(self, other):
        if (other.b * self.a - other.a * self.b) == 0:
            return None
        delt = other.b * self.a - other.a * self.b
        u = (other.a * (self.y0 - other.y0) - other.b * (self.x0 - other.x0)) / delt
        w = (self.a * (self.y0 - other.y0) - self.b * (self.x0 - other.x0)) / delt
        if 0 <= u <= 1 and 0 <= w <= 1:
            return self.get_point(u)
        else:
            return None


class Polygon(object):

    def __init__(self):
        self.points = llist.dllist()

    def add_point(self, x, y):
        self.points.append(Point(x, y))

    def clear(self):
        self.points.clear()

    def draw(self, flag=True):
        if flag:
            glColor3f(0, 0, 1)
        else:
            glColor3f(1, 0, 1)

        for i in range(len(self.points)):
            glBegin(GL_LINES)
            if i == len(self.points)-1:
                glVertex2f(*self.points[i].get_coord())
                glVertex2f(*self.points[0].get_coord())
            else:
                glVertex2f(*self.points[i].get_coord())
                glVertex2f(*self.points[i+1].get_coord())
            glEnd()


class WeilerAtherton(object):

    def __init__(self, clip_polygon, subject_polygon):
        self.clip_polygon = clip_polygon
        self.subject_polygon = subject_polygon
        self.reversed = False
        self.points = []
        # make copies for clipping by Weilor-Azerton
        self.copy_clip_polygon = None
        self.copy_subject_polygon = None

    @staticmethod
    def det(p1, p2):
        return p1.x * p2.y - p2.x * p1.y

    def difference(self, subject_polygon, clip_polygon):
        if self.copy_subject_polygon is None and self.copy_clip_polygon is None:
            subject_polygon = deepcopy(self.subject_polygon.points)
            self.copy_subject_polygon = deepcopy(self.subject_polygon.points)
            clip_polygon = deepcopy(self.clip_polygon.points)
            self.copy_clip_polygon = deepcopy(self.clip_polygon.points)

        polygon = self.clipping(subject_polygon, clip_polygon)
        self.copy_clip_polygon, self.copy_subject_polygon = None, None
        return polygon

    def clipping(self, subject_polygon, clip_polygon):
        def intersections(intersection,subject_polygon,clip_polygon):
            for i in range(len(subject_polygon)):
                current_subj_polygon = subject_polygon[i]
                for j in range(len(clip_polygon)):
                    current_clip_polygon = clip_polygon[j]
                    line_a = LineParam(current_subj_polygon, subject_polygon[(i + 1) % (len(subject_polygon))])
                    line_b = LineParam(current_clip_polygon, clip_polygon[(j + 1) % (len(clip_polygon))])
                    point = line_a.intersect(line_b)
                    if point is not None:
                        if point not in intersection:
                            self.points.append(point)
                            if not bool_find(subject_polygon, point):
                                subject_polygon.insert(point, subject_polygon.nodeat((i+1) % (len(subject_polygon))))
                            if not bool_find(clip_polygon, point):
                                clip_polygon.insert(point, clip_polygon.nodeat((j+1) % (len(clip_polygon))))
                            intersection[point] = (current_clip_polygon, point)
                            return True
            return False

        #   correcting mistakes for lines finding exactly needed nodes
        def corrections(intersection, clip_polygon, subject_polygon):
            for key, value in intersection.items():
                intersection[key] = (prev(clip_polygon, find_node(clip_polygon, value[1])).value, value[1])

        # visiting each node of the list and making the result polygon
        def traversing(subject_list, enter, exit, polygon, transit, start_point, clip_list):
            subject_list_node = contains(subject_list, transit)
            if subject_list_node is None:
                return None
            delete(enter, transit.value)
            while subject_list_node is not None and (not bool_contains(exit, subject_list_node)) and (not bool_contains(enter, subject_list_node)):
                polygon.appendright(subject_list_node.value)
                subject_list_node = next(subject_list, subject_list_node)
                if subject_list_node.value == start_point:
                    return None
            return contains(clip_list, subject_list_node)

        listOfIntersections = {}
        result = []
        flag = True
        while flag:
            flag = intersections(listOfIntersections, subject_polygon, clip_polygon)
        enter = llist.dllist()
        exit = llist.dllist()
        corrections(listOfIntersections, clip_polygon, subject_polygon)

        for i in range(len(subject_polygon)):
            current_subj_polygon = subject_polygon[i]
            if current_subj_polygon in listOfIntersections:
                if self.det(subject_polygon[(i + 1) % (len(subject_polygon))] - subject_polygon[i],
                                    listOfIntersections[current_subj_polygon][1]-listOfIntersections[current_subj_polygon][0]) > 0:
                    sign = True
                else:
                    sign = False

                if sign:
                    enter.appendright(current_subj_polygon)
                else:
                    exit.appendright(current_subj_polygon)

        enter, exit = exit, enter
        # Reverse order of a clip_polygon
        clip_polygon = llist.dllist(list(clip_polygon)[::-1])

        subject_list = subject_polygon
        clip_list = clip_polygon

        # going through list of verticies
        while len(enter) > 0:
            polygon = llist.dllist()
            start_point_polygon = enter.first.value
            count = 0
            transit = enter.first
            while transit is not None and (count == 0 or (count > 0 and start_point_polygon != transit.value)):
                transit = traversing(subject_list, enter, exit, polygon, transit, start_point_polygon, clip_list)
                subject_list, clip_list = clip_list, subject_list
                enter, exit = exit, enter
                count += 1
            result.append(polygon)

        if len(result) == 0:
            if len(subject_polygon) == 0 or len(clip_polygon) == 0:
                return []

            result.append(subject_polygon)
            result.append(clip_polygon)
        return result


pyglet.gl.glClearColor(1, 1, 1, 1)

clip_polygon = Polygon()
subject_polygon = Polygon()
clipping = WeilerAtherton(clip_polygon, subject_polygon)
polygon = []
clipped = False
global operation


@window.event
def on_draw():
    global polygon, subject_polygon, clip_polygon
    global clipped
    window.clear()
    glClear(GL_COLOR_BUFFER_BIT)
    if not clipped:
        glLineWidth(1)
        subject_polygon.draw()
        clip_polygon.draw(flag=False)
    for i in range(len(polygon)):
        glColor3f(0, 0, 0)
        glLineWidth(4)
        llen = len(polygon[i])
        for j in range(llen):
            glBegin(GL_LINES)
            glVertex2f(*polygon[i][j].get_coord())
            glVertex2f(*polygon[i][(j + 1) % llen].get_coord())
            glEnd()


@window.event
def on_key_press(symbol, modifiers):
    global polygon, subject_polygon, clip_polygon
    if symbol == key.D:
        polygon = clipping.difference(clipping.copy_subject_polygon, clipping.copy_clip_polygon)
    elif symbol == key.SPACE:
        subject_polygon.clear()
        clip_polygon.clear()
        polygon = []
    elif symbol == key.R:
        clip_polygon, subject_polygon = subject_polygon, clip_polygon
        clipping.subject_polygon, clipping.clip_polygon = clipping.clip_polygon, clipping.subject_polygon
        clipping.reversed = True


@window.event
def on_mouse_press(x, y, button, modifiers):
    if button & mouse.LEFT:
        subject_polygon.add_point(x, y)
    elif button & mouse.RIGHT:
        clip_polygon.add_point(x, y)


if __name__ == '__main__':
    pyglet.app.run()
