using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;


namespace arrayDemo
{
    /// <summary>
    /// 此Demo 演示的是有关顺序表的Demo 
    /// </summary>
    class DATA {

       public String key;//结点的关键字
       public String name;
       public int age;
    }

    /// <summary>
    /// 定义顺序表的结构
    /// </summary>
     class ArrType {

        static  int MAXLEN = 120;//定义顺序表的最大存储的值
        DATA[]listData=new DATA[MAXLEN+1];//保存顺序表的结构化数组

        int listLen; //表示循序表已经保存的结点的数量

        public void ArrTypeInit(ArrType at) {
            at.listLen = 0;//初始化循序表为空表

        }


        public int ArrLength(ArrType at) {//返回循序表的元素的数量

            return at.listLen;
        
        
        }

        /// <summary>
        /// 插入指定位置上的元素到相应的列表当中
        /// </summary>
        /// <param name="at"></param>
        /// <param name="n"></param>
        /// <param name="data"></param>
        /// <returns></returns>
        public int ArrInsert(ArrType at, int n, DATA data) {
            //int i;
            if (at.listLen >= MAXLEN) { 
            //循序表结点已经超过了最大的数量
                Console.WriteLine("顺序表已满，不能插入结点！");
                return 0;

            
            }

            if(n<1||n>at.listLen-1){

                //插入的序号不正确
                Console.WriteLine("插入序号错误，不能插入相应的元素！");

                return 0;//返回0，表示插入不成功
            }
            //满足上面2个条件，执行插入元素的逻辑代码
            for (int i = at.listLen; i >= n ; i--)
			{
                at.listData[i+1]=at.listData[i];
			 
			}//将顺序表中的数据向后移动


            at.listData[n] = data;//完成循环之后，插入结点
            at.listLen++;    //操作完成之后顺序表的结点数量加1

            return 1;//成功插入元素，返回1

        
        
        }

        /// <summary>
        /// 增加元素到顺序表的尾部
        /// </summary>
        /// <param name="at"></param>
        /// <param name="data"></param>
        /// <returns></returns>
        public int ArrAdd(ArrType at, DATA data)
        {

            if (at.listLen >= MAXLEN)
            {
                //表示顺序表已满
                Console.WriteLine("顺序表已经满了，不能再添加结点了！");

                return 0;

            }


            at.listData[at.listLen++] = data; 
            //注意，必须是要at.listLen++ 而不是++at.listLen,否则回报空指针错误
            return 1;//操作成功，返回1



        }

        /// <summary>
        /// 删除指定位置上的结点的值
        /// 
        /// </summary>
        /// <param name="at"></param>
        /// <param name="n"></param>
        /// <returns></returns>
        public int ArrDelete(ArrType at, int n)
        {
            //int i;
            if(n<1||n>at.listLen+1){

                Console.WriteLine("删除结点序号错误，不能删除此节点。");
                return 0;
            }

            for (int i = n; i < at.listLen; i++)//将顺序表的数据向前移动
            {
                at.listData[i]=at.listData[i+1];

                
            }
            at.listLen--;//顺序表元素数量减1
            return 1;//成功删除，返回1


        }

        /// <summary>
        /// 根据顺序表的元素的下标来处理相应的元素
        /// 根据顺序号来返回数据元素
        /// </summary>
        /// <param name="at"></param>
        /// <param name="n"></param>
        /// <returns></returns>
        public DATA ArrFindByNum(ArrType at,int n) {
        //根据序号返回数据元素
            if (n < 1 || n > at.listLen + 1)
            {

                //如果元素序号不正确
                Console.WriteLine("结点序号错误，不能返回结点！");
                return null;    //列表里面找不到相应的元素，则返回null

            }
            return at.listData[n-1];
        
        }


        /// <summary>
        /// 根据关键字来查询 所需的结点
        /// </summary>
        /// <param name="at"></param>
        /// <param name="key"></param>
        /// <returns></returns>
        public int ArrFindByCount(ArrType at, String key)
        {

            //int i;
            for (int i = 1; i <=at.listLen; i++)
            {
                if(at.listData[i-1].key.CompareTo(key)==0)//如果查找到了所需的结点
                {

                    return i;//则返回结点的顺序号
                }
                
            }
            return 0;//搜索整个链表没有找到相应的元素，则返回0
        }

        /// <summary>
        /// 显示整个顺序表中的所有的结点
        /// </summary>
        /// <param name="at"></param>
        /// <returns></returns>
        public int showAll(ArrType at)//
        {

            for (int i = 0; i <at.listLen; i++)
            {
                Console.WriteLine(string.Format("({0},{1},{2}) ",at.listData[i].key,at.listData[i].name,at.listData[i].age));
                
            }

            return 0;

        }


    
    }





    class Program
    {
        static void Main(string[] args)
        {
            //Console.WriteLine();
            int i;
            ArrType at = new ArrType();//定义顺序列表变量
            DATA pdata;    //定义结点保存引用类型变量
            String key; //保存关键字
            Console.WriteLine("顺序表的操作演示：");
            at.ArrTypeInit(at);   //初始化顺序表

            Console.WriteLine("初始化顺序表完成：");
            
            do{
                //循环添加节点数据
                String input = Console.ReadLine();

                DATA data = new DATA();
                input = input.Trim();
                data.key=input.Split(new char[]{})[0].Trim();
                data.name = input.Split(new char[] { })[1].Trim();
                data.age = Int32.Parse(input.Split(new char[] { })[2].Trim());


                if (data.age != 0)//若年龄不为0
                {

                    if (at.ArrAdd(at, data) == 0)
                    {
                        //若添加结点失败
                        break;//退出死循环
                    }

                }
                else {
                    //若年龄为0，退出死循环
                    break;
                }

            
            }while(true);

            Console.WriteLine("\n顺序表中的结点的顺序为：\n");
            at.showAll(at);//显示所有结点的顺序

            Console.WriteLine("\n要取出的结点的序号：");
            i = Int32.Parse(Console.ReadLine().Trim());   //输入结点的序列号
            pdata = at.ArrFindByNum(at,i);  //按照序号查找结点
            if (pdata != null)   //若返回的结点的引用不为null
            {

                Console.WriteLine(string.Format("第{0}个结点为:({1},{2},{3}) ", i, pdata.key, pdata.name, pdata.age));

            }
            else {

                Console.WriteLine(string.Format("节点序号为{0}的结点不存在！！！",i));
            }

            Console.WriteLine("\n要查找的关键字:");
            key = Console.ReadLine().Trim();
            i = at.ArrFindByCount(at,key);
            pdata = at.ArrFindByNum(at,i);
            if (pdata != null)   //若返回的结点的引用不为null
            {

                Console.WriteLine(string.Format("第{0}个结点为:({1},{2},{3}) ", i, pdata.key, pdata.name, pdata.age));

            }
            else
            {

                Console.WriteLine(string.Format("节点序号为{0}的结点不存在！！！", i));
            }



            Console.ReadKey();
        }
    }
}
