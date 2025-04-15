class RodaLoop(object):

    David: bool = True
    Erik: bool = False
    Paulo: bool = True
    variavel1: int = 0

    def __init__(self:"RodaLoop", roda: bool, count: int):
        self.rodando = roda
        self.contador = count
        
    def loop(self:"RodaLoop") -> int:

        while self.rodando:
            self.contador = self.contador + 1
            if self.contador > 10:
                self.rodando = False
        return self.contador
    
    
def testaDeclaracao(x: int, lista: [int]) -> int:
    global variavel1
    variavel1 = 2 + 2

    for i in range(0, len(lista)):
        if lista[i] == 1:
            x = x + 1
        else:
            x = x - 1
    return x
    

print(RodaLoop(True, 0).loop())
print(testaDeclaracao(1, [1, 2, 3]))

mensagem = "teste"
professor = "christiano"

# teste comentario
print(1 + professor + 3)