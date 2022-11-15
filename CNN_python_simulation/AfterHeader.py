
from Utils import *

def centerForm_2_cornerForm(centerForm):
    w=centerForm[2]
    h=centerForm[3]
    return (
              centerForm[0]-w/2,
              centerForm[1]-h/2,
              centerForm[0] + w / 2,
              centerForm[1] + h / 2,
              )
class AfterHeader():#输出大于阈值的prob    []
    prob_threshold=0.6
    image_size=(128,96)
    feature_map_w_h=(16,12)
    min_boxes_0 =[10, 16, 24]
    center_variance = 0.1
    size_variance = 0.2
    def __init__(s):
        pass
    def forward(s,classification_header_out,regression_header_out):
        l_real_bbox_centerForm=[]
        l_prob=[]
        feature每个像素上几个location=len(classification_header_out)//2
        H=len(classification_header_out[0])
        W=len(classification_header_out[0][0])
        assert H==s.feature_map_w_h[1]  and W==s.feature_map_w_h[0]
        for iy in range(H):
            for ix in range(W):
                for i_box in range(feature每个像素上几个location):
                    if(classification_header_out[i_box*2+1][iy][ix]-classification_header_out[i_box*2][iy][ix]>math.log(   s.prob_threshold/(1-s.prob_threshold)  ,math.e   )):
                        def ttt4263():
                            ret=[]
                            for i_tt436 in range(4):
                                ret.append(regression_header_out[i_box*4+i_tt436][iy][ix])
                            return ret
                        location=ttt4263()#【4】
                        ##location 2 bbox
                        def location_2_bbox(location):
                            min_box=s.min_boxes_0[i_box]
                            prior=[
                                   (ix+0.5)/W,
                                   (iy+0.5)/H,
                                   min_box/s.image_size[0],
                                   min_box/s.image_size[1]
                                   ]
                            bbox_centerForm=[
                                location[0]*s.center_variance*prior[2]+prior[0],
                                location[1]*s.center_variance*prior[3]+prior[1],
                                math.exp(  location[2]*s.size_variance  )*prior[2],
                                math.exp(  location[3]*s.size_variance  )*prior[3]
                            ]
                            return   bbox_centerForm
                        bbox_centerForm=location_2_bbox(location)
                        ##nms

                        ##乘以原图长宽
                        real_bbox_centerForm=bbox_centerForm[:]
                        real_bbox_centerForm[0]=bbox_centerForm[0]*s.image_size[0]
                        real_bbox_centerForm[1]=bbox_centerForm[1]*s.image_size[1]
                        real_bbox_centerForm[2]=bbox_centerForm[2]*s.image_size[0]
                        real_bbox_centerForm[3]=bbox_centerForm[3]*s.image_size[1]
                        l_real_bbox_centerForm.append( real_bbox_centerForm   )
                        l_prob.append(     math.exp(classification_header_out[i_box*2+1][iy][ix])/( math.exp(classification_header_out[i_box*2+1][iy][ix])+ math.exp(classification_header_out[i_box*2][iy][ix])    )    )
        return l_prob,l_real_bbox_centerForm
def draw(imageName,imageDir,image_save_Dir,l_real_bbox_centerForm,l_prob):
    import cv2,os
    orig_image = cv2.imread(os.path.join(imageDir,imageName))
    orig_image=cv2.resize(orig_image, (128,96))#W*H*C
    for i in range(len(l_real_bbox_centerForm)):
        box = l_real_bbox_centerForm[i]
        box_cornerForm=centerForm_2_cornerForm(box)
        cv2.rectangle(orig_image, (int(box_cornerForm[0]), int(box_cornerForm[1])), (int(box_cornerForm[2]), int(box_cornerForm[3])), (0, 0, 255), 1)
        label = f"{l_prob[i]:.2f}"
        cv2.putText(orig_image, label, (int(box[0]  ), int(box[1] ) - 10),
                    cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 0, 255), 1)
    cv2.imwrite(os.path.join(image_save_Dir, imageName), orig_image)

def draw_in_raw_image(imageName,imageDir,image_save_Dir,l_real_bbox_centerForm,l_prob):
    import cv2,os
    orig_image = cv2.imread(os.path.join(imageDir,imageName))
    raw_shape=orig_image.shape
    print("raw_shape:",raw_shape)
    rawH=raw_shape[0]
    rawW=raw_shape[1]
    ct=0
    for i in range(len(l_real_bbox_centerForm)):
        box = l_real_bbox_centerForm[i]
        box_cornerForm=centerForm_2_cornerForm(box)
        cv2.rectangle(orig_image, (int(box_cornerForm[0]*rawW/128),
                                   int(box_cornerForm[1]*rawH/96)),
                                  (int(box_cornerForm[2]*rawW/128),
                                   int(box_cornerForm[3]*rawH/96)),
                                  (0, 0, 255), 1)
        label = f"{l_prob[i]:.2f}"
        cv2.putText(orig_image, label, (int(box[0] *rawW/128 ), int(box[1] *rawH/96) - 10),
                    cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 0, 255), 1)
        ct+=1
    cv2.putText(orig_image, str(ct), (10,10),
                cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 0, 255), 1)
    orig_image=cv2.resize(orig_image, (rawW,rawH))
    cv2.imwrite(os.path.join( image_save_Dir, imageName.replace(".","_rawSize.")), orig_image)