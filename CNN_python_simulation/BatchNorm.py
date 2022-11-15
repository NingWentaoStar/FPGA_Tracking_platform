from Utils import  *



class BatchNorm():
    def __init__(s,name):#比如"base_net.1.1.running_var"那name就是base_net.1.1
        s.weight=None
        s.bias=None
        s.running_mean=None
        s.running_var=None
        s.epsilon=1e-5
        s.name=name
        s.fp_equivalent_weight=None
        s.fp_equivalent_bias=None
        s.equivalent_weight=None
        s.equivalent_bias=None
    def forward(s,input):
        for ic,c in enumerate(input):
            for iy,y in enumerate(c):
                for ix,x in enumerate(y):
                    input[ic][iy][ix]=   x*s.equivalent_weight[ic]   +s.equivalent_bias[ic]
        return  input
    # #ok.V1
    # def load(s,state_dict):
    #     for key,val in state_dict.items():
    #         i_last_dot= key.rindex(".")
    #         if(   s.name==    key[: i_last_dot    ]):
    #             paraName=key[i_last_dot+1:]
    #             if(paraName=="weight"):
    #                 s.weight=val
    #             elif(paraName=="bias"):
    #                 s.bias=val
    #             elif(paraName=="running_mean"):
    #                 s.running_mean=val
    #             elif(paraName=="running_var"):
    #                 s.running_var=val
    #             else:
    #                 assert 1
    #     ###
    #     s.fp_equivalent_weight=[]
    #     s.fp_equivalent_bias=[]
    #     for ic,(weight,bias,running_mean,running_var) in enumerate( zip(s.weight,s.bias,s.running_mean,s.running_var) ):
    #         s.fp_equivalent_weight.append(weight/(sqrt(running_var)+s.epsilon))
    #         s.fp_equivalent_bias.append(    bias-running_mean*weight/(sqrt(running_var)+s.epsilon)    )
    #     s.weight = None
    #     s.bias = None
    #     s.running_mean = None
    #     s.running_var = None
    #     s.epsilon = None
    #     s.equivalent_weight=[]
    #     s.equivalent_bias=[]
    #     s.equivalent_weight = fp_l_2_bin_l(s.fp_equivalent_weight, *name_2_DATA_bitsNum_POS_point[s.name]["equivalent_weight"])
    #     s.equivalent_bias = fp_l_2_bin_l(s.fp_equivalent_bias, *name_2_DATA_bitsNum_POS_point[s.name]["equivalent_bias"])
    def load(s,state_dict):
        for key,val in state_dict.items():
            i_last_dot= key.rindex(".")
            if(   s.name==    key[: i_last_dot    ]):
                paraName=key[i_last_dot+1:]
                if(paraName=="equivalent_weight"):
                    s.fp_equivalent_weight=val
                elif(paraName=="equivalent_bias"):
                    s.fp_equivalent_bias=val
                else:
                    assert 1
        s.equivalent_weight = fp_l_2_bin_l(s.fp_equivalent_weight, *name_2_DATA_bitsNum_POS_point[s.name]["equivalent_weight"])
        s.equivalent_bias = fp_l_2_bin_l(s.fp_equivalent_bias, *name_2_DATA_bitsNum_POS_point[s.name]["equivalent_bias"])





