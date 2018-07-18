using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace chapter02
{
    /**
     把顺序表看作是一个泛型类，类名叫 SeqList<T>。”Seq”是英文单
词”Sequence”的前三个字母。SeqList<T>类实现了接口 IListDS<T>。用数组来存
储顺序表中的元素，在 SeqList<T>类中用字段 data 来表示。由于经常需要在顺
序表中插入或删除数据元素，所以要求顺序表的表长是可变的。因此，数组的容
量需要设计得特别大，可以用 System.Array 的 Length 属性来表示。但为了说明
顺序表的最大长度（顺序表的容量），在 SeqList<T>类中用字段 maxsize 来表示。
maxsize 的值可以根据实际需要修改，这通过 SeqList<T>类中构造器的参数 size
来实现。顺序表中的元素由 data[0]开始依次顺序存放，由于顺序表中的实际元素
个数一般达不到 maxsize，因此，在 SeqList<T>类中需要一个字段 last 表示顺序
表中最后一个数据元素在数组中的位置。如果顺序表中有数据元素时，last 的变
化范围是 0 到 maxsize-1，如果顺序表为空，last=-1。具体表示见图 2.1 所示。由
于顺序表空间的限制，当往顺序表中插入数据元素需要判断顺序表是否已满，顺
序表已满不能插入元素。所以，SeqList<T>类除了要实现接口 IListDS<T>中的方
法外，还需要实现判断顺序表是否已满等成员方法。
     */
    public class SeqList<T>:IListDS<T>
    {
        private int maxsize;     //顺序表的容量
        private T[] data;        //数组，用于存储顺序表中的数据元素
        private int last;        //指示顺序表最后一个元素的位置

        //索引器
        public T this[int index]
        {
            get { return data[index]; }
            set { data[index] = value; }
        }


        //最后一个数据元素位置的属性
        public int Last
        {
            get { return last; }

        }

        //容量属性
        public int Maxsize
        {

            get { return maxsize; }
            set { maxsize = value; }
        }


        public SeqList(int size)
        {
            data=new T[size];
            maxsize = size;
            last = -1;
        }

        //求顺序表长度
        public int GetLength()
        {
            return last + 1;
        }


        //清空顺序表
        public void Clear()
        {

            last = -1;

        }
        //判断顺序表是否为空
        public bool IsEmpty()
        {

            if (last == -1)
            {
                return true;
            }
            else
            {
                return false;
            }
        }
        //判断顺序表是否为满
        public bool IsFull()
        {
            if (last == maxsize - 1)
            {
                return true;
            }
            else
            {
                return false;
            }
        }

        //在顺序表的末尾添加新元素
        public void Append(T item)
        {
            if (IsFull())
            {
                Console.WriteLine("List is full.");
                return;
            }
            data[++last] = item;
        }
        //在顺序表的第i个数据元素的位置插入一个数据元素
        public void Insert(T item, int i)
        {
            if (IsFull())
            {
                Console.WriteLine("List is full.");
                return;
            }

            if (i < 1 || i > last + 2)
            {
                Console.WriteLine("Position is error!");
                return;
            }

            if (i == last + 2)
            {
                data[last + 1] = item;
            }
            else
            {
                for (int j = last; j >=i-1 ; j--)
                {
                    data[j+1]=data[j];
                    
                }
                data[i - 1] = item;
            }

            ++last;
        }
        //删除顺序表的第i个数据元素
        public T Delete(int i)
        {
            T tmp = default(T);
            if (IsEmpty())
            {
                Console.WriteLine("List is empty。");
                return tmp;
            }
            if (i < 1 || i > last + 1)
            {
                Console.WriteLine("Position is error.");
                return tmp;
            }

            if (i == last + 1)
            {
                tmp=data[last--];
            }
            else
            {
                tmp=data[i-1];
                for (int j = i; j <=last; j++)
                {
                    data[j]=data[j+1];
                    
                }

            }

            --last;
            return tmp;
        }


        //获得顺序表的第I个数据元素
        public T GetElem(int i)
        {
            if (IsEmpty() || (i < 1) || (i > last + 1))
            {
                Console.WriteLine("List is empty or Position is error!");
                return default(T);
            }

            return data[i-1];

        }
        //在顺序表中查找值为value的数据元素
        public int Locate(T value)
        {
            if (IsEmpty())
            {
                Console.WriteLine("List is Empty.");
                return -1;
            }

            int i = 0;
            for (i = 0; i <=last ; i++)
            {
                if (value.Equals(data[i])) { break; }
            }

            if (i > last) return -1;
            return i;
        }



        //顺序表的倒置的算法
        public void ReversSeqList(SeqList<T> L)
        {
            T tmp = default(T);
            int len = L.GetLength();
            for (int i = 0; i <= len / 2; ++i)
            {
                tmp = L[i];
                L[i] = L[len - i];
                L[len - i] = tmp;
            }
        }


        //二路归并(从小到大升序排列)
        //算法的时间复杂度是 O(m+n)，m 是 La 的表长，n 是 Lb 的表长。
        public SeqList<int> Merge(SeqList<int> La, SeqList<int> Lb)
        {
            SeqList<int> Lc = new SeqList<int>(La.Maxsize + Lb.Maxsize);
            int i = 0;
            int j = 0;
            int k = 0;

            //两个表中都有数据元素
            while ((i <= La.GetLength() - 1) && (j <= Lb.GetLength() - 1))
            {
                if (La[i]<Lb[j]) Lc.Append(La[i++]);
                else Lc.Append(Lb[j++]);
            }

            //a表中还有数据元素
            while (i <= (La.GetLength() - 1))
            {
                Lc.Append(La[i++]);
            }


            //b表中还有数据元素
            while (j <= (Lb.GetLength() - 1))
            {
                Lc.Append(Lb[j++]);
            }





            return Lc;

        }


        /**
         已知一个存储整数的顺序表 La，试构造顺序表 Lb，要求顺序表 Lb 中
只包含顺序表 La 中所有值不相同的数据元素。
         */
        //数据去重的操作
        //算法的时间复杂度是 O(m+n)，m 是 La 的表长，n 是 Lb 的表长
        public SeqList<int> Purge(SeqList<int> La)
        {

            SeqList<int> Lb = new SeqList<int>(La.Maxsize);


            //将a表中的第1个元素赋值给b表
            Lb.Append(La[0]);



            //依次出来a表中的数据元素
            for (int i = 1; i < La.GetLength(); i++)
            {
                int j = 0;
                //查看b表中有无与a表中相同的数据元素
                for ( j = 0; j < Lb.GetLength(); j++)
                {
                    //有相同的数据元素
                    if (La[i].CompareTo(Lb[j]) == 0) { break; }
                    
                }

                //没有相同的数据元素，将a表中的数据元素附加到b表的末尾
                if (j > Lb.GetLength() - 1)
                {
                    Lb.Append(La[i]);
                }
                
            }
            return Lb;
        }









    }
}
