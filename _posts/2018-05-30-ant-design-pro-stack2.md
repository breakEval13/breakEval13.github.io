---
layout: post
categories: yield
title: Ant-Design-Pro 基础问题[第四天]
date: 2018-05-30 11:09:03 +0800
description: 一些在群里遇到的问题，以及见解还有解决方案。
keywords: react,ant-design-pro,aliyun
---

其中是我在QQ群 `362329545`遇到的 问题，整理成问答录，希望能解决入门的烦恼，个人见解，如果有那里有错误请指出了我会积极改进，方便他人。



## 问答录[3问]



###  问
   * <a href="#form_1" target="_self">如何编辑修改在一个Form内进行操作</a>
   * <a href="#form_2" target="_self">关于Ant(StandardTable)的默认数据格式</a>






### 答

####   <span id = "form_1"><font>在Form如何进行编辑以及新增数据。</font></span>

  * 开始这个演示，注意注释描述,代码不一定能运行，只是整体做个介绍

    ```js
        const CreateForm = Form.create()(props => {
        const {modalVisible, form, handleAdd, handleEdit, handleModalVisible, formData, formType} = props;  /** 传入的可变变量 **/
        const okHandle = () => {
            form.validateFields((err, fieldsValue) => {
            if (err) return;
            form.resetFields();
            if (formType === 0) handleAdd(fieldsValue); /**判断类型进行展示数据，以及新增*/
            if (formType === 1) handleEdit(fieldsValue);
            });
        };
        return (
            <Modal
            title="微信配置"
            visible={modalVisible}

            onOk={okHandle} //修改和新增主要看这里  

            onCancel={() => handleModalVisible()}
            >
            //初始化数据 formData

            <FormItem labelCol={{span: 5}} wrapperCol={{span: 15}} label="公钥">
                {form.getFieldDecorator('public_key', {
                initialValue: Object.keys(formData || {}).length ? formData.public_key : '',
                rules: [{required: true, message: 'Please input  public_key...'}],
                })(<Input placeholder="请输入"/>)}
            </FormItem>

            /**这里定义的是 select 的数据以及修改的时候数据的加载 可以保证数据正常显示。**/
            /**目前存在一些疑惑，为什么通过formData 直接绑定，在修改的时候展示的是key 不是 value 通过外部传递就可以。**/
            <FormItem labelCol={{span: 5}} wrapperCol={{span: 15}} label="应用类型">
                {form.getFieldDecorator('channel_way', {
                initialValue: Object.keys(formData || {}).length ? formData.channel_way : '',
                })(
                <Select placeholder="不限" style={{maxWidth: 200, width: '100%'}}>
                    {channelWayData.map(item => (
                    <Option key={item.id} value={item.id}>
                        {item.desc}
                    </Option>
                    ))}
                </Select>
                )}
            </FormItem>
            </Modal>
        );
        });

          handleEdit = fields => {
                message.success(JSON.stringify(fields))
                const {paymentConfigId} = this.state;
                const {dispatch} = this.props;
                fields.channel_id = paymentConfigId;
                dispatch({
                type: 'parkingPayManager/modifyChannel',
                payload: JSON.stringify(fields),
                callback: () => {
                    dispatch({
                    type: 'parkingPayManager/queryChannelList',
                    callback: (e) => {
                        message.success("修改成功，列表已经刷新！")
                    },
                    })
                    this.setState({
                    modalVisible: false, // 清除
                    });
                },
                })
            }

            handleAdd = fields => {
                const {dispatch} = this.props;
                /**switchPress true = 0, fasle = 1 方便数据存储*/ 
                fields.channel_status = this.switchPress(fields.channel_status);
                /**触发action触发model层的state的初始化*/
                dispatch({
                type: 'parkingPayManager/insertChannel',
                payload: JSON.stringify(fields),
                callback: () => {
                    dispatch({
                    type: 'parkingPayManager/queryChannelList',
                    callback: (e) => {
                        message.success('successfully ');
                    },
                    })
                        this.setState({
                            modalVisible: false,
                        });
                    },
                });
            };
        /**传递数据*/
        state = {
            paymentTypeData: [
            {
                id: 1,
                desc: "支付宝",
            }
            ,
            {
                id: 0,
                desc: "微信",
            }
            ,
            ],
            channelWayData: [
            {
                id: 0,
                desc: "小程序,公众号",
            }, {
                id: 1,
                desc: "APP",
            },
            ],
            selectedRows: [],
            formType: 0, /** 0 add  1 edit 定义Form的弹出的模式  **/
            formData: {},
        }
        /**
        * @param  {state:Object} ... 里面多个参数 
        *
        */
        const {isLoading,...[省略]} = this.state;

        const parentMethods = {
            handleAdd: this.handleAdd,
            handleModalVisible: this.handleModalVisible,
            optionChildrenDataTemp: optionChildrenData,
            formData: formData,
            formType: formType,

            handleEdit: this.handleEdit,
            channelWayData: channelWayData,
            paymentTypeData: paymentTypeData,
        };


         /**
         * 组件参数配置（render => （这里面定义的组件））
         * @param {array}  parentMethods 是我们传递的参数组[多个]
         *
         * @param {boolean}  modalVisible 模态框 弹出还暗示隐藏的状态
         */
         <CreateForm {...parentMethods} modalVisible={modalVisible}/>

         /** models 里面的方法 */
         /**
         *@param {Object} payload 是我们提交的参数，或者是用来修改数据等。
         *@param {function} callback 执行成功的回调可以将参数 call回去。
         **/
         effects: {
            * insertChannelCfg({payload, callback}, {call, put}) {
                const response = yield call(insertParkManagerChannelCfg, payload);
                console.log("result Data  successfully");
                console.log(response);
                yield put({
                    type: 'updateStateInsertChannelCfg',
                    payload: response.data,
                    /**
                    *  (response.success) ? response.data : [], 也可以这样去写
                    */
                });
                if (response.success) {
                    callback();
                    /*
                    * callback(response);
                    * 可以将参数携带回去，也可以不携带，具体看下需求
                    **/
                    }
                },
         }
        /**
        *@param {reducers} 通过reducers -> updateStateInsertChannelCfg 将数据传递回去
        **/
        reducers:{
            updateStateInsertChannelCfg(state, action) {
            return {
                ...state,
                InsertChannelCfgNum: action.payload,
                /** InsertChannelCfgNum 记得在 state 里面注册 否则会出现undef */
            }
            },
         }

         /***
         * 解答一下 `namespace: 'parkingPayManager'`
         *  我们在dispatch 里面通过type 调用的 是先通过 namespace 再去找到具体的(effects)内的执行器。
         *
         **/

        /** services [用来发送请求，并且将数据携带回去] **/

        /**
        *@param {JSON} params 我们传递的参数，
        *@func  request 是自己封装的一个请求的方法。
        **/
        export async function insertParkManagerChannelCfg(params) {
            return request('/proxy-post/insertChannelCfg', {
                method: 'POST', data: params || {},
            })
        }
    ```

####  <span id = "form_2"><font>Ant StandardTable 数据格式</font></span>

     ```js
      /**
      * 我们通过 model获得的数据将如何渲染出去是个问题，StandardTable是一个 ant封装的组件，如果你要用他的组件就要满足他的数据格式
      **/
        const {parkingPayManager: {channelData}} = this.props;
            const newdata = {
            list: channelData,
            pagination: {
                total: channelData.length,
                pageSize: 10,
                current: 1,
            },
        };

        ...

            <StandardTable
              selectedRows={selectedRows}
              loading={isLoading}
              data={newdata}
              columns={columns}
            />
     ```


转载请注明出处，本文采用 [CC4.0](http://creativecommons.org/licenses/by-nc-nd/4.0/) 协议授权
