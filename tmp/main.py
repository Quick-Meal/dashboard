# -*- coding: utf-8 -*-
"""
Created on Fri Oct 12 12:05:46 2018

@author: ZZH
"""

import os
import cv2
from glob import glob
import random
import operator
import time
import numpy as np
import functions
import warnings
warnings.filterwarnings('ignore')  # 不打印 warning

from skimage import io,transform
import tensorflow as tf
import split_class
import eval_class

# 全局变量：参数信息
THRESHOLD_VALUE = None       # 预测结果域值
MODEL_FILE = None            # 神经网络 meta 文件
MODEL_CHECKPOINT = None      # 神经网络 checkpoint 文件夹
INIT_FOLDER = None           # 初始数据 文件夹
YES_FOLDER = None            # 已识别数据 文件夹
NOT_FOLDER = None            # 问题数据 文件夹
TRAINING_DATA_PATH = None    # 训练数据集目录
TRAINING_DATA_INDEX = None   # 训练数据命名顺序
POLLING_TIME_SLOT = None     # 轮询时间间隔
BATCH_SIZE = None            # 批处理数目
LATEST_DAYS = None           # 扫描最新几天

#分类标签
digital_label  = {0:'0',1:'1',2:'2',3:'3',4:'4',5:'5',6:'6',7:'7',8:'8',9:'9',}
#图片文件
IMAGE_WIDTH  = 40
IMAGE_HIGH   = 50

# 读取配置文件并设置参数
def read_configuration():
    global THRESHOLD_VALUE,MODEL_FILE,MODEL_CHECKPOINT,INIT_FOLDER,NOT_FOLDER,BATCH_SIZE,\
           YES_FOLDER,TRAINING_DATA_PATH,TRAINING_DATA_INDEX,POLLING_TIME_SLOT,LATEST_DAYS
    f = open("configuration/configuration.txt", "r")
    lines = f.readlines()
    for line,i in zip(lines,range(len(lines))):
        if line == '#threshold_value\n':
            THRESHOLD_VALUE = float(lines[i+1].replace('\n',''))
            #print(THRESHOLD_VALUE)
        elif line == '#polling_time_slot\n':
            POLLING_TIME_SLOT = float(lines[i+1].replace('\n',''))
            #print(POLLING_TIME_SLOT)
        elif line == '#latest_days\n':
            LATEST_DAYS = int(lines[i+1].replace('\n',''))
            #print(LATEST_DAYS)
        elif line == '#batch_size\n':
            BATCH_SIZE = int(lines[i+1].replace('\n',''))
        elif line == '#model_file\n':
            MODEL_FILE =lines[i+1].replace('\n','')
            #print(MODEL_FILE)
        elif line == '#model_checkpoint\n':
            MODEL_CHECKPOINT =lines[i+1].replace('\n','')
            #print(MODEL_CHECKPOINT)
        elif line == '#init_folder\n':
            INIT_FOLDER = lines[i+1].replace('\n','')
            #print(UNIDENTIFIED_FOLDER)
        elif line == '#yes_folder\n':
            YES_FOLDER = lines[i+1].replace('\n','')
            #print(IDENTIFIED_FOLDER)
        elif line == '#not_folder\n':
            NOT_FOLDER = lines[i+1].replace('\n','')
            #print(IDENTIFIED_FOLDER)
        elif line == '#training_data_path\n':
            TRAINING_DATA_PATH = lines[i+1].replace('\n','')
            #print(TRAINING_DATA_PATH)
    f.close()
    TRAINING_DATA_INDEX = TRAINING_DATA_PATH + '/index_dict.txt'
    #print(TRAINING_DATA_INDEX)
       
def identify_image():
    time_string = time.strftime("%Y%m%d%H%M", time.localtime())
    if os.path.exists('log/'+time_string) == False:
        os.mkdir('log/'+time_string)
    log_file_1 = open('log/'+time_string+'/cut.txt','a+')       # 切割出问题图像
    log_file_2 = open('log/'+time_string+'/identify.txt','a+')  # 识别出问题的图像
    log_file_3 = open('log/'+time_string+'/wrong.txt','a+')     # 导致程序异常的图像
    exist_exception = False # 是否存在程序异常
    fail_identify = False   # 是否存在识别异常
    fail_cut = False        # 是否存在裁剪异常
    
    print('------------start------------')
    functions.create_train(TRAINING_DATA_PATH)
    print('loading graph ...')
    new_split = split_class.TOD() # 裁剪网络
    new_eval = eval_class.RFD(MODEL_FILE,MODEL_CHECKPOINT,THRESHOLD_VALUE)
    print('load successfully!')
    wait_index = 0
    
    while(True):
        if wait_index>10000:
            wait_index = 0
        time_folder = os.listdir(INIT_FOLDER)
        
        # 更新最新最近100天
        time_folder = sorted(time_folder,reverse=True)
        today_string = time.strftime("%Y%m%d", time.localtime())
        select_time_folder = []
        for tmp in time_folder:
            if functions.caltime(today_string,tmp) <= LATEST_DAYS:
                select_time_folder.append(tmp)
        start_time_length = len(time_folder)
        
        # 处理每个时间文件夹
        for tmp in select_time_folder: 
            current_time_folder = INIT_FOLDER + '/' + tmp
            total_sleep_times = 0
            
            # 处理每个社区
            community_folder = os.listdir(current_time_folder)
            for item in community_folder:
                current_image_folder = current_time_folder + '/' + item
                print(current_image_folder)
                
                #图片已写入
                if os.path.exists(current_image_folder + '/0.txt') == True:
                    #all_list = glob(current_image_folder + '/*.*')
                    all_list_ = os.listdir(current_image_folder)
                    all_list = [current_image_folder+'/'+i for i in all_list_]
                    img_list = []
                    # 选择未处理图片
                    for ii in all_list:
                        if ii[-4:] == '.jpg' or ii[-4:]=='.bmp' or ii[-4:]=='.png':
                            if os.path.exists(ii[:-4]+'.txt') == False:
                                img_list.append(ii)
                                
                    if len(img_list)>0:
                        for img_path in img_list:
                            try: # 尝试裁剪+识别
                                #new_folder = img_path.split('\\')[-1].split('.')[-2]
                                img = cv2.imread(img_path)
                                print(img_path)
                                #cv2.imshow('image',img)
                                #cv2.waitKey(0)
                                # 如果图像读取出问题
                                if img.shape is None:
                                    log_file_3.write(img_path)
                                    log_file_3.write('\n')
                                    log_file_3.flush()
                                    os.fsync(log_file_3)
                                    continue
                                try:
                                    true_boxes, fix_method = new_split.detect(img)
                                except:
                                    try:
                                        true_boxes, fix_method = new_split.detect(img,use_select=False)
                                    except:
                                        print('Error:',img_path)
                                        fail_cut = True
                                        log_file_1.write(img_path)
                                        log_file_1.write('\n')
                                        log_file_1.flush()
                                        os.fsync(log_file_1)
                                        
                                # 如果没有结果
                                if true_boxes is None:
                                    print('Error:',img_path)
                                    fail_cut = True
                                    log_file_1.write(img_path)
                                    log_file_1.write('\n')
                                    log_file_1.flush()
                                    os.fsync(log_file_1)
                                    true_boxes = functions.recover_boxes()
                                    #fix_method = 'static'
                                else:
                                    crop_dir = img_path[:-4]
                                    if not os.path.exists(crop_dir):
                                        os.mkdir(crop_dir)
                                        
                                    tag = 1
                                    im_width, im_height = img.shape[1],img.shape[0]
                                    for boxes in true_boxes:
                                        ymin,xmin,ymax,xmax =  boxes
                                        (left, right, top, bottom) = (xmin * im_width, xmax * im_width,
                                                                      ymin * im_height, ymax * im_height)
                                        x1 = int(left)
                                        y1 = int(top)
                                        x2 = int(right)
                                        y2 = int(bottom)
                                        number_img = img[y1:y2, x1:x2]
                                        number_img = cv2.resize(number_img, (40, 50),
                                                                interpolation=cv2.INTER_CUBIC)
                                        crop_name = crop_dir + '/'+ str(tag) + '.bmp'
                                        tag = tag + 1
                                        cv2.imwrite(crop_name, number_img)
                                    ############### 调用函数 ###################
                                    evalimgs = functions.read_img(crop_dir,IMAGE_WIDTH,IMAGE_HIGH)
                                    eval_result, fail_identify = new_eval.predict(evalimgs)
                                    #print('place-3')
                                    print(eval_result, fail_identify)
                                    functions.writetotext(crop_dir,eval_result)
                                    functions.movefiletotraining(crop_dir,eval_result,TRAINING_DATA_PATH,TRAINING_DATA_INDEX)
                                    #cv2.imshow('image',img)
                                    #cv2.waitKey(0)
                                    ############### 调用函数 ###################
                                    if len(eval_result)!=5 or fail_identify== True:
                                        log_file_2.write(img_path)
                                        log_file_2.write('\n')
                                        log_file_2.flush()
                                        os.fsync(log_file_2)
                            except:
                                log_file_3.write(img_path)
                                log_file_3.write('\n')
                                log_file_3.flush()
                                os.fsync(log_file_3)
                                
                    os.remove(current_image_folder + '/0.txt')
                    f = open(current_image_folder + '/1.txt','w')
                    f.close()
        end_time_length = len(os.listdir(INIT_FOLDER))  # 结束长度
        if(start_time_length == end_time_length):
            wait_index += 1
            print('[%d] sleep for new data... ' % wait_index)
            time.sleep(int(POLLING_TIME_SLOT*60))

    log_file_1.close() # cut
    log_file_2.close() # identy
    log_file_3.close()
    print('------------end------------')
    
if __name__ == '__main__': 
    # 读取配置文件
    read_configuration()
    # 识别图像
    identify_image()
    
    
    
