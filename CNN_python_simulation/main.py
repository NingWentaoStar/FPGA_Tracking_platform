from Utils import  *
from BatchNorm  import   *
from Conv import   *
from  ReLU import *
from  AfterHeader  import   *
import pickle
l_base_net=[
    NormalConv_KernelSize3_Padding1(name="base_net.0.0",stride=2),
    BatchNorm(name="base_net.0.1"),
    ReLU(),


    DepthWise_Conv(name="base_net.1.0",stride=1  ),
    BatchNorm(name="base_net.1.1"),
    ReLU(),
    DepthWiseSeparable_Conv(name="base_net.1.3"  ),
    BatchNorm(name="base_net.1.4"),
    ReLU(),


    DepthWise_Conv(name="base_net.2.0", stride=2),
    BatchNorm(name="base_net.2.1"),
    ReLU(),
    DepthWiseSeparable_Conv(name="base_net.2.3" ),
    BatchNorm(name="base_net.2.4"),
    ReLU(),


    DepthWise_Conv(name="base_net.3.0", stride=1),
    BatchNorm(name="base_net.3.1"),
    ReLU(),
    DepthWiseSeparable_Conv(name="base_net.3.3" ),
    BatchNorm(name="base_net.3.4"),
    ReLU(),


    DepthWise_Conv(name="base_net.4.0", stride=2),
    BatchNorm(name="base_net.4.1"),
    ReLU(),
    DepthWiseSeparable_Conv(name="base_net.4.3" ),
    BatchNorm(name="base_net.4.4"),
    ReLU(),


    DepthWise_Conv(name="base_net.5.0", stride=1),
    BatchNorm(name="base_net.5.1"),
    ReLU(),
    DepthWiseSeparable_Conv(name="base_net.5.3"),
    BatchNorm(name="base_net.5.4"),
    ReLU(),


    DepthWise_Conv(name="base_net.6.0", stride=1),
    BatchNorm(name="base_net.6.1"),
    ReLU(),
    DepthWiseSeparable_Conv(name="base_net.6.3"),
    BatchNorm(name="base_net.6.4"),
    ReLU(),


    DepthWise_Conv(name="base_net.7.0", stride=1),
    BatchNorm(name="base_net.7.1"),
    ReLU(),
    DepthWiseSeparable_Conv(name="base_net.7.3"),
    BatchNorm(name="base_net.7.4"),
    ReLU(  ),
]
classification_header=[
    Bias_DepthWise_Conv(name="classification_headers.0.0", stride=1),
    ReLU(),
    Bias_DepthWiseSeparable_Conv(name="classification_headers.0.2")
]
regression_header=[
    Bias_DepthWise_Conv(name="regression_headers.0.0", stride=1),
    ReLU(),
    Bias_DepthWiseSeparable_Conv(name="regression_headers.0.2")
]
afterHeader=AfterHeader( )
###layer初始化
import   json
pth_name="slim-320-5[equi]"
with open(f"{pth_name}.json","r") as f:
    state_dict=json.load(f)
for layer in l_base_net:
    layer.load( state_dict  )
for layer in classification_header:
    layer.load(state_dict)
for layer in regression_header:
    layer.load( state_dict  )
###image
import  os
import   cv2,torch
###
Version=668
path_for_json_and_img=os.path.join("./result",pth_name,f"V{Version}")
os.mkdir(path_for_json_and_img)
with open(os.path.join(path_for_json_and_img,f"{pth_name}--V{Version}.json"),"w") as f:
    json.dump(name_2_DATA_bitsNum_POS_point,f)
###
img_src_dir=r"E:\APP_projects_and_files\py\_AI_Face_and_emotion\_image_for_test\image_for_test"
listdir=os.listdir(img_src_dir)
for file_path in listdir:
    img_path = os.path.join(img_src_dir, file_path)
    orig_image = cv2.imread(img_path)
    image = cv2.cvtColor(orig_image, cv2.COLOR_BGR2RGB)
    image=(image-127.0)/128.0#W*H*C
    input=cv2.resize(image, (128,96))#W*H*C
    input=torch.from_numpy(input.astype(np.float32)).permute(2, 0, 1).numpy()
    input=fp_l_2_bin_l(input,16,15)
    ###forward
    ct=0
    for layer in l_base_net:
        shape_input=np.array(input).shape
        num_ele=shape_input[0]*shape_input[1]*shape_input[2]
        input=layer.forward(input)
        shape=np.array(input).shape
        if(not (isinstance(layer,BatchNorm) or isinstance(layer,ReLU))):
            print(f"\n\n{layer.name}   {type(layer)}   {shape_input}({num_ele}个数)->{shape}")
        else:
            if (isinstance(layer, ReLU)):
                layer_name = "ReLU没有名字"
            else:
                layer_name = layer.name
            print(f"{layer_name}   {type(layer)}   {shape_input}->{shape}")

        fp_input=bin_l_2_fp_l(input)
        # print(len(fp_input))
        ct+=1
    classification_header_out=input
    for layer in classification_header:
        shape_input=np.array(classification_header_out).shape
        num_ele=shape_input[0]*shape_input[1]*shape_input[2]
        classification_header_out=layer.forward(classification_header_out)
        shape=np.array(classification_header_out).shape
        print(f"\n\n{type(layer)}   {shape_input}({num_ele}个数)->{shape}")

    regression_header_out=input
    for layer in regression_header:
        regression_header_out=layer.forward(regression_header_out)
        shape=np.array(regression_header_out).shape
        print(shape)
    fp_classification_header_out=bin_l_2_fp_l(classification_header_out)
    fp_regression_header_out=bin_l_2_fp_l(regression_header_out)
    l_prob,l_real_bbox_centerForm=afterHeader.forward(fp_classification_header_out,fp_regression_header_out)
    shape = np.array(l_real_bbox_centerForm).shape
    print(shape)
    draw(imageName=file_path,
         imageDir=img_src_dir,
         image_save_Dir=path_for_json_and_img,
         l_real_bbox_centerForm=l_real_bbox_centerForm,
         l_prob=l_prob)
    draw_in_raw_image(imageName=file_path,
         imageDir=img_src_dir,
         image_save_Dir=path_for_json_and_img,
         l_real_bbox_centerForm=l_real_bbox_centerForm,
         l_prob=l_prob)
    # break
# print(input)