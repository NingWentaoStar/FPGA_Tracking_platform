# import pickle,os
# class CheckPoint_at_end_in_loop():#放在循环体的最末
#     def __init__(s,name,load:bool,dump:bool):
#         s.name=name
#         s.ct=0#循环了几次
#         s.load=load
#         s.dump=dump
#         s.__file_name_prefix="CheckPoint_"+s.name
#     @property
#     def  file_name(s):
#         return s.__file_name_prefix+"_"+s.ct+".txt"
#     def get_obj_if_exist___and___dump(s,obj):
#         s.ct+=1
#         if()
