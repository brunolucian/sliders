from datetime import datetime

class Person:
    _count = 0
    
    def __init__(self, name, birth = None):
        self.id = Person._count
        #
        Person._count += 1
        
        self.name = name
        try:
            self.birth = datetime.strptime(birth, '%Y-%m-%d').date()
        except TypeError:
            self.birth = None

    def __repr__(self):
        return '{} - {} ({})'.format(self.id, self.name, self.birth)

    def age(self):
        return (datetime.now().date() - self.birth).days

emma = Person("Emma", "1996-09-26")
storm = Person("Storm", "1993-03-26")
