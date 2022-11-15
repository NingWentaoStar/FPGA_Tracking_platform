
from FixedPoint import  FixedPoint

class   ReLU():
    def __init__(self):
        pass
    def forward(s,input):
        for ic,c in enumerate(input):
            for iy,y in enumerate(c):
                for ix,x in enumerate(y):
                    input[ic][iy][ix]=x if not x.is_negative() else FixedPoint(data=0,DATA_bitsNum=x.DATA_bitsNum,POS_point=x.POS_point)
        return input
    def load(self,state_dict):
        pass