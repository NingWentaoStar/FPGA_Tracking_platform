from Utils import  *

class EleWise_Product():
    def two_dimension(mat1,mat2):
        assert  len(mat1)==len(mat2)
        assert len(mat1[0])==len(mat2[0])
        out=[ [0 for ix in range(mat1[0])] for  iy in range(mat1) ]
        for iy,y1 in enumerate(mat1):
            y2=mat2[iy]
            for ix,x1 in enumerate(y1):
                x2=y2[ix]
                out[iy][ix]=x1*x2
        return out

class DotProduct():
    def two_dimension(mat1,mat2):
        assert  len(mat1)==len(mat2)
        assert len(mat1[0])==len(mat2[0])
        out=FixedPoint(0,1,1)
        for iy,y1 in enumerate(mat1):
            y2=mat2[iy]
            for ix,x1 in enumerate(y1):
                x2=y2[ix]
                out+=x1*x2
        return out
    def three_dimension(tensor1,tensor2):
        assert  len(tensor1)==len(tensor2)
        assert len(tensor1[0])==len(tensor2[0])
        assert len(tensor1[0][0])==len(tensor2[0][0])
        out=FixedPoint(0,1,1)
        for ic,c1 in enumerate(tensor1):
            c2=tensor2[ic]
            for iy,y1 in enumerate(c1):
                y2=c2[iy]
                for ix,x1 in enumerate(y1):
                    x2=y2[ix]
                    out+=x1*x2
        return out
class Conv():
    def __init__(s):
        s.filters=None
        s.stride=None
        s.padding=None
        s.name=None
    def forward(s,x):
        return x
    def load(s,state_dict):
        pass
class NormalConv_KernelSize3_Padding1( ):
    def __init__(s,name,stride):
        s.fp_filters=None
        s.filters=None
        s.stride=stride
        s.name=name
    def forward(s,input):
        reFix(input, *name_2_DATA_bitsNum_POS_point[s.name]["input"])
        C_in = len(input)
        H = len(input[0])
        W = len(input[0][0])
        C_out = len(s.filters)
        output=[]
        for filter in s.filters:
            mat=[]
            iy = 0  # 卷积中心y坐标
            while (iy <= H - 1):
                ix = 0
                line = []
                while (ix <= W - 1):
                    def ttttt3524():
                        dotProduct = FixedPoint(data=0,DATA_bitsNum=1,POS_point=1)
                        for index_c, c1 in enumerate(filter):
                            c2 = input[index_c]
                            for index_y_filter in range(0,3):
                                index_y_input=iy-1+index_y_filter
                                if(index_y_input<0 or index_y_input>=H):
                                    continue
                                for index_x_filter in range(0, 3):
                                    index_x_input = ix - 1 + index_x_filter
                                    if (index_x_input < 0 or index_x_input >= W):
                                        continue
                                    dotProduct += c1[index_y_filter][index_x_filter]*c2[index_y_input][index_x_input]
                        return  dotProduct
                    line.append(ttttt3524())
                    ix += s.stride
                mat.append(line)
                iy += s.stride
                # if(iy%20==0):
                #     print(iy)
            output.append(mat)
            print("tt2345")
        return  output
    def load(s,state_dict):
        for key,val in state_dict.items():
            i_last_dot = key.rindex(".")
            if (s.name == key[: i_last_dot]):
                paraName = key[i_last_dot + 1:]
                if (paraName == "weight"):
                    s.fp_filters = val
                    s.filters=fp_l_2_bin_l(s.fp_filters,*name_2_DATA_bitsNum_POS_point[s.name]["filters"]  )
                else:
                    print(paraName)


class DepthWise_Conv():#3x3 filter;in channel==out channel;padding=1
    # kernel_size=3
    # padding=1
    def __init__(s,name,stride):
        s.filters=None
        s.stride=stride
        s.name=name
    def forward(s,input):#input:c*H*W
        reFix(input, *name_2_DATA_bitsNum_POS_point[s.name]["input"])
        assert len(input)==len(s.filters)
        H=len(input[0])
        W=len(input[0][0])
        output=[]
        for ic,filter in enumerate(s.filters):
            mat=[]
            iy=0#卷积中心y坐标
            while(iy<=H-1):
                ix=0
                line=[]
                while(ix<=W-1):
                    def ttt315():
                        ret_mat=[
                            [
                                input[ic][iy-1][ix-1] if (iy-1>=0and ix-1>=0) else  FixedPoint(0,*name_2_DATA_bitsNum_POS_point[s.name]["input"]),
                                input[ic][iy-1][ix] if (iy-1>=0) else   FixedPoint(0,*name_2_DATA_bitsNum_POS_point[s.name]["input"]),
                                input[ic][iy-1][ix+1] if (iy-1>=0and ix+1<=W-1) else   FixedPoint(0,*name_2_DATA_bitsNum_POS_point[s.name]["input"])
                            ],
                            [
                                input[ic][iy ][ix - 1] if ( ix - 1 >= 0) else   FixedPoint(0,*name_2_DATA_bitsNum_POS_point[s.name]["input"]),
                                input[ic][iy ][ix] ,
                                input[ic][iy ][ix + 1] if ( ix + 1 <= W - 1) else   FixedPoint( 0,*name_2_DATA_bitsNum_POS_point[s.name]["input"])
                            ],
                            [
                                input[ic][iy + 1][ix - 1] if (iy + 1 <= H-1 and ix - 1 >= 0) else   FixedPoint( 0,*name_2_DATA_bitsNum_POS_point[s.name]["input"]),
                                input[ic][iy + 1][ix] if (iy + 1 <= H-1) else   FixedPoint( 0,*name_2_DATA_bitsNum_POS_point[s.name]["input"]),
                                input[ic][iy + 1][ix + 1] if (iy + 1 <= H-1 and ix + 1 <= W - 1) else   FixedPoint( 0,*name_2_DATA_bitsNum_POS_point[s.name]["input"])
                            ]
                        ]
                        return ret_mat
                    line.append(DotProduct.two_dimension(filter[0],ttt315()  ))
                    ix+=s.stride
                mat.append(line)
                iy+=s.stride
            output.append(mat)
        return   output
    def load(s,state_dict):
        for key,val in state_dict.items():
            i_last_dot = key.rindex(".")
            if (s.name == key[: i_last_dot]):
                paraName = key[i_last_dot + 1:]
                if (paraName == "weight"):
                    s.fp_filters = val
                    s.filters=fp_l_2_bin_l(s.fp_filters,*name_2_DATA_bitsNum_POS_point[s.name]["filters"]  )
                else:
                    print(paraName)
class DepthWiseSeparable_Conv():#filters:out*in*1*1;stride=1;padding=0;
    def __init__(s,name):
        s.filters=None
        s.name=name
    def forward(s,input):#W,H不变，C变
        reFix(input, *name_2_DATA_bitsNum_POS_point[s.name]["input"])

        C_in=len(input)
        H=len(input[0])
        W=len(input[0][0])
        output=[]
        C_out=len(s.filters)
        for filter in s.filters:
            tmp_mat=[]
            for iy in range(H):
                tmp_line=[]
                for ix in range(W):
                    tmp_tensor=[     [[input[ic_in][iy][ix]]] for ic_in in range(C_in) ]
                    tmp_line.append(     DotProduct.three_dimension(tmp_tensor,filter))
                tmp_mat.append(tmp_line)
            output.append(tmp_mat)
        return  output
    def load(s,state_dict):
        for key,val in state_dict.items():
            i_last_dot = key.rindex(".")
            if (s.name == key[: i_last_dot]):
                paraName = key[i_last_dot + 1:]
                if (paraName == "weight"):
                    s.fp_filters = val
                    s.filters=fp_l_2_bin_l(s.fp_filters,*name_2_DATA_bitsNum_POS_point[s.name]["filters"]  )
                else:
                    print(paraName)







class Bias_DepthWise_Conv():#3x3 filter;in channel==out channel;padding=1
    # kernel_size=3
    # padding=1
    def __init__(s,name,stride):
        s.filters=None
        s.bias=None
        s.stride=stride
        s.name=name
    def forward(s,input):#input:c*H*W
        assert len(input)==len(s.filters)
        H=len(input[0])
        W=len(input[0][0])
        output=[]
        for ic,filter in enumerate(s.filters):
            mat=[]
            iy=0#卷积中心y坐标
            while(iy<=H-1):
                ix=0
                line=[]
                while(ix<=W-1):
                    def ttt315():
                        ret_mat=[
                            [
                                input[ic][iy-1][ix-1] if (iy-1>=0and ix-1>=0) else  FixedPoint(0,*name_2_DATA_bitsNum_POS_point[s.name]["input"]),
                                input[ic][iy-1][ix] if (iy-1>=0) else  FixedPoint(0,*name_2_DATA_bitsNum_POS_point[s.name]["input"]),
                                input[ic][iy-1][ix+1] if (iy-1>=0and ix+1<=W-1) else  FixedPoint(0,*name_2_DATA_bitsNum_POS_point[s.name]["input"])
                            ],
                            [
                                input[ic][iy ][ix - 1] if ( ix - 1 >= 0) else  FixedPoint(0,*name_2_DATA_bitsNum_POS_point[s.name]["input"]),
                                input[ic][iy ][ix] ,
                                input[ic][iy ][ix + 1] if ( ix + 1 <= W - 1) else  FixedPoint(0,*name_2_DATA_bitsNum_POS_point[s.name]["input"])
                            ],
                            [
                                input[ic][iy + 1][ix - 1] if (iy + 1 <= H-1 and ix - 1 >= 0) else  FixedPoint(0,*name_2_DATA_bitsNum_POS_point[s.name]["input"]),
                                input[ic][iy + 1][ix] if (iy + 1 <= H-1) else  FixedPoint(0,*name_2_DATA_bitsNum_POS_point[s.name]["input"]),
                                input[ic][iy + 1][ix + 1] if (iy + 1 <= H-1 and ix + 1 <= W - 1) else  FixedPoint(0,*name_2_DATA_bitsNum_POS_point[s.name]["input"])
                            ]
                        ]
                        return ret_mat
                    line.append(DotProduct.two_dimension(filter[0],ttt315()  ) + s.bias[ic]  )
                    ix+=s.stride
                mat.append(line)
                iy+=s.stride
            output.append(mat)
        return   output
    def load(s,state_dict):
        for key,val in state_dict.items():
            i_last_dot = key.rindex(".")
            if (s.name == key[: i_last_dot]  ):
                paraName = key[i_last_dot + 1:]
                if (paraName == "weight"):
                    s.fp_filters = val
                    s.filters=fp_l_2_bin_l(s.fp_filters,*name_2_DATA_bitsNum_POS_point[s.name]["weight"]  )
                elif(paraName=="bias"):
                    s.fp_bias = val
                    s.bias=fp_l_2_bin_l(s.fp_bias,*name_2_DATA_bitsNum_POS_point[s.name]["bias"]  )
                else:
                    print(paraName)
class Bias_DepthWiseSeparable_Conv():#filters:out*in*1*1;stride=1;padding=0;
    def __init__(s,name):
        s.filters=None
        s.bias=None
        s.name=name
    def forward(s,input):#W,H不变，C变
        C_in=len(input)
        H=len(input[0])
        W=len(input[0][0])
        output=[]
        C_out=len(s.filters)
        for ic,filter in enumerate(s.filters):
            tmp_mat=[]
            for iy in range(H):
                tmp_line=[]
                for ix in range(W):
                    tmp_tensor=[     [[input[ic_in][iy][ix]]] for ic_in in range(C_in) ]
                    tmp_line.append(     DotProduct.three_dimension(tmp_tensor,filter) + s.bias[ic]   )
                tmp_mat.append(tmp_line)
            output.append(tmp_mat)
        return  output
    def load(s,state_dict):
        for key,val in state_dict.items():
            i_last_dot = key.rindex(".")
            if (s.name == key[: i_last_dot]):
                paraName = key[i_last_dot + 1:]
                if (paraName == "weight"):
                    s.fp_filters = val
                    s.filters=fp_l_2_bin_l(s.fp_filters,*name_2_DATA_bitsNum_POS_point[s.name]["weight"]  )
                elif(paraName=="bias"):
                    s.fp_bias = val
                    s.bias=fp_l_2_bin_l(s.fp_bias,*name_2_DATA_bitsNum_POS_point[s.name]["bias"]  )
                else:
                    print(paraName)