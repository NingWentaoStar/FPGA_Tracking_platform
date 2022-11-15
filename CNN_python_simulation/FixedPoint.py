from Utils import  *
from copy import deepcopy
from  scy639.binary二进制 import fi3
# class FixedPoint():
#     def __init__(s,data,DATA_bitsNum,POS_point):
#         if(isinstance(data,str)):
#             s.data=data
#         else:
#             s.data=fi2(data,DATA_bitsNum=DATA_bitsNum,POS_point=POS_point)
#         s.DATA_bitsNum=DATA_bitsNum
#         s.POS_point=POS_point
#     def __add__(s, other):
#         a=s.data
#         b=other.data
#         if(s.POS_point<other.POS_point):
#             a=a+"0"* (other.POS_point-s.POS_point)
#         elif(s.POS_point>other.POS_point):
#             b=b+"0"* (s.POS_point-other.POS_point)
#         data=addBinary_2(a,b)
#         new=deepcopy(s)
#         new.data=data
#         new.DATA_bitsNum = len(data) - 1
#         new.POS_point = max(s.POS_point, other.POS_point)
#         return new
#     def __mul__(s, other):
#         data=mulBinary_2(s.data,other.data)
#         new=deepcopy(s)
#         new.data=data
#         new.DATA_bitsNum = len(data) - 1
#         new.POS_point = s.POS_point + other.POS_point
#         return    new
#
#     def reFix(s,new_DATA_bitsNum,new_POS_point):
#         new_INTEGER_bitsNum=new_DATA_bitsNum-new_POS_point
#         old_INTEGER_bitsNum=s.DATA_bitsNum-s.POS_point
#         new_SIGN=s.data[0]
#         if(new_POS_point<=s.POS_point):
#             new_FRAC=s.data[-s.POS_point:new_POS_point-s.POS_point]
#         else:
#             # print("【WARNING】536")
#             new_FRAC = s.data[-s.POS_point: ]+"0"*(new_POS_point-s.POS_point)
#
#         if(new_INTEGER_bitsNum<=old_INTEGER_bitsNum):
#             new_INTEGER=s.data[-(s.POS_point+new_INTEGER_bitsNum): -s.POS_point]
#         else:
#             # print("【WARNING】234")
#             new_INTEGER=new_SIGN*(new_INTEGER_bitsNum-old_INTEGER_bitsNum)+s.data[1: -s.POS_point]#负数补1，正数补0.吗？
#
#         s.data=new_SIGN+new_INTEGER+new_FRAC
#         s.DATA_bitsNum=new_DATA_bitsNum
#         s.POS_point=new_POS_point
#     def display(s):
#         print( "TODO" )
#     def to_float(s):
#         int_val=int(s.data,2)
#         if(s.data[0]=="1"):
#             int_val=int_val-(1<<(s.DATA_bitsNum+1))
#         fp_val=int_val/(1<<s.POS_point)
#         return fp_val
class FixedPoint():
    @staticmethod
    def float_2_FixedPoint(data:float,DATA_bitsNum,POS_point):
        assert isinstance(data,float)
        data=fi3(data,DATA_bitsNum=DATA_bitsNum,POS_point=POS_point)
        return  FixedPoint(data,DATA_bitsNum,POS_point)
    def __init__(s,data:int,DATA_bitsNum,POS_point):
        assert  isinstance(data,int)
        s.data=data
        s.DATA_bitsNum=DATA_bitsNum
        s.POS_point=POS_point
    def __add__(s, other):
        self_data=s.data
        other_data=other.data
        ##整数位少且为负的数要pad 1
        if(s.DATA_bitsNum-s.POS_point> other.DATA_bitsNum-other.POS_point):
            if(other.is_negative()):
                #pad 1
                other_data=(  1<<(1+s.DATA_bitsNum)  )-(   1<<(1+other.DATA_bitsNum )  )+other_data
        elif (s.DATA_bitsNum - s.POS_point <other.DATA_bitsNum - other.POS_point):
            if (s.is_negative()):
                # pad 1
                self_data =  (1 << (1 + other.DATA_bitsNum  )) - (
                            1 << (1 + s.DATA_bitsNum  )) + self_data
        ##小数点对齐
        if(s.POS_point>= other.POS_point):
            new_POS_point=s.POS_point
            new_data=self_data+(other_data   <<  (s.POS_point-other.POS_point))
        else:
            new_POS_point = other.POS_point
            new_data=other_data+(self_data  <<  (other.POS_point-s.POS_point))
        ##溢出（只取低max(DATA+1)位）
        new_DATA_bitsNum = new_POS_point+( max(  s.DATA_bitsNum-s.POS_point,other.DATA_bitsNum-other.POS_point  ))
        new_data = new_data & ((1 <<(new_DATA_bitsNum+1))-1)
        return FixedPoint(new_data,new_DATA_bitsNum,new_POS_point)
    def __mul__(s, other):
        self_data = s.data
        other_data = other.data
        ##负数 pad 1到
        L=(1 + s.DATA_bitsNum)+(1 + other.DATA_bitsNum)#self_data*other_data最多L-1位
        if (other.is_negative()):
            # pad 1
            other_data = (1 << L) - (1 << (1 + other.DATA_bitsNum)) + other_data
        if (s.is_negative()):
            # pad 1
            self_data = (1 << L) - (   1 << (1 + s.DATA_bitsNum)) + self_data
        ##乘
        new_data=self_data*other_data
        new_POS_point=s.POS_point+other.POS_point
        ##溢出
        new_DATA_bitsNum = L-2
        new_data = new_data & ((1 <<new_DATA_bitsNum+1)-1)

        return FixedPoint(new_data,new_DATA_bitsNum,new_POS_point)
    def reFix(s,new_DATA_bitsNum,new_POS_point):
        s.data=fi3(   s.to_float(  ), new_DATA_bitsNum,new_POS_point )
        s.DATA_bitsNum=new_DATA_bitsNum
        s.POS_point=new_POS_point
    def is_negative(s):
        tmp=bin(s.data)
        return  len(tmp)-2==s.DATA_bitsNum+1  and  tmp[2]=="1"
    def to_float(s):
        int_val=s.data
        if(s.is_negative()):
            int_val=int_val-(1<<(s.DATA_bitsNum+1))
        fp_val=int_val/(1<<s.POS_point)
        return fp_val
    @property
    def in_float(s):
        return s.to_float()

def fp_l_2_bin_l(fp_l,DATA_bitsNum,POS_point):
    def _fp_l_2_bin_l(fp_l):
        if (isinstance(fp_l, float)):
            return FixedPoint.float_2_FixedPoint(fp_l, DATA_bitsNum,POS_point)
        elif(isinstance(fp_l,list)  ):
            for i, item in enumerate(fp_l):
                fp_l[i] = _fp_l_2_bin_l(item)
            return fp_l
        elif(  isinstance(fp_l,np.ndarray)):
            fp_l=fp_l.tolist()
            for i, item in enumerate(fp_l):
                fp_l[i] = _fp_l_2_bin_l(item)
            return fp_l
        elif(isinstance(fp_l,np.float32)):
            return FixedPoint.float_2_FixedPoint(fp_l.item(), DATA_bitsNum,POS_point)
        else:
            assert 0,f"type(fp_l):  {type(fp_l)}"
    return _fp_l_2_bin_l(fp_l)
def bin_l_2_fp_l(bin_l ):
    def _bin_l_2_fp_l(bin_l):
        if (isinstance(bin_l, FixedPoint)):
            return bin_l.to_float()
        elif(isinstance(bin_l,list)  ):
            new=[]
            for i, item in enumerate(bin_l):
                new.append(_bin_l_2_fp_l(item))
            return new
        elif(  isinstance(bin_l,np.ndarray)):
            bin_l=bin_l.tolist()
            new=[]
            for i, item in enumerate(bin_l):
                new.append(_bin_l_2_fp_l(item))
            return new
        else:
            assert 0,f"type(bin_l):  {type(bin_l)}"
    return _bin_l_2_fp_l(bin_l)
# def reFix(l,DATA_bitsNum,POS_point):
#     def _reFix(l):
#         if (isinstance(l, FixedPoint)):
#             return l.reFix(  DATA_bitsNum,POS_point)
#         elif(isinstance(l,list)):
#             for i, item in enumerate(l):
#                 l[i] = _reFix(item)
#             return l
#         else:
#             assert 0,f"type(l):  {type(l)}"
#     return _reFix(l)


# def reFix(l,DATA_bitsNum,POS_point):
#     def _reFix(l):
#         if (isinstance(l, FixedPoint)):
#             l.reFix(  DATA_bitsNum,POS_point)
#         elif(isinstance(l,list)):
#             for i, item in enumerate(l):
#                 l[i] = _reFix(item)
#             return l
#         else:
#             assert 0,f"type(l):  {type(l)}"
#     return _reFix(l)

def reFix(l,DATA_bitsNum,POS_point):
    def _reFix(l):
        if (isinstance(l, FixedPoint)):
            l.reFix(  DATA_bitsNum,POS_point)
        elif(isinstance(l,list)):
            for i, item in enumerate(l):
                _reFix(l[i])
        else:
            assert 0,f"type(l):  {type(l)}"
    _reFix(l)

#ok
if(__name__=="__main__"):
    x = 1.25
    y =-2.75
    fixedPoint1 = FixedPoint.float_2_FixedPoint(x, 3 + 2, 2)
    fixedPoint2 = FixedPoint.float_2_FixedPoint(y, 3 + 3, 3)
    fixedPoint3=fixedPoint1+fixedPoint2
    print(fixedPoint3.to_float())
    print(fixedPoint3)
    print("over")
#ok
if(__name__=="__main__"):
    x = -1.25
    y =2.75
    fixedPoint1 = FixedPoint.float_2_FixedPoint(x, 3 + 2, 2)
    fixedPoint2 = FixedPoint.float_2_FixedPoint(y, 3 + 3, 3)
    fixedPoint3=fixedPoint1+fixedPoint2
    print(fixedPoint3.to_float())
    print(fixedPoint3)
    print("over")
#ok
if(__name__=="__main__"):
    import random
    max_error=-1
    x_when_error_is_max=None
    fixedPoint_when_error_is_max=None
    ct=100
    while(ct):
        x=random.random()*random.randint(-999,999)
        fixedPoint=FixedPoint.float_2_FixedPoint(x,10+5,5)
        误差=abs(x- fixedPoint.to_float())
        print( 误差)
        if(误差>=max_error):
            max_error=误差
            x_when_error_is_max=x
            fixedPoint_when_error_is_max=fixedPoint
        ct-=1
    print("over")
    print(    max_error)
    print(
            x_when_error_is_max,
            fixedPoint_when_error_is_max)
#ok
if(__name__=="__main__"):
    import random
    add_max_error=-1
    mul_max_error=-1
    mul_max_relative_error=-1
    ct=100
    while(ct):
        x = random.random() * random.randint(-999, 999)
        y = random.random() * random.randint(-999, 999)
        fixedPoint1 = FixedPoint.float_2_FixedPoint(x, 11 + 5, 5)
        fixedPoint2= FixedPoint.float_2_FixedPoint(y, 12 + 6, 6)
        # fixedPoint1 = FixedPoint.float_2_FixedPoint(x, 11 + 66, 66)
        # fixedPoint2= FixedPoint.float_2_FixedPoint(y, 12 + 77, 77)
        add误差 =abs( (x+y)-(fixedPoint1+fixedPoint2).to_float())
        print(add误差)
        if (add误差 >= add_max_error):
            add_max_error = add误差
        mul误差 = abs((x*y)-(fixedPoint1*fixedPoint2).to_float())
        mul_相对误差=mul误差/(abs(x*y))
        print(mul误差)
        if (mul误差 >= mul_max_error):
            mul_max_error = mul误差
            mul_max_relative_error=mul_相对误差
        ct-=1
    print("loop end")
    print(    add_max_error)
    print(    mul_max_error)
    print(    mul_max_relative_error)
    print("over")
