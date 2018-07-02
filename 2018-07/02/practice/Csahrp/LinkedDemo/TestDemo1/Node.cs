using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TestDemo1
{
    public class Node<T>
    {


        private T data;//数据yu
        private Node<T> next;//引用域

        public Node(T  val,Node<T> p) {

            data = val;
            next = p;
        }


        public Node(Node<T> p)
        {
            next = p;
        }


        public Node(T val)
        {

            data = val;
            next = null;

        }

        //默认构造器
        public Node() {
        
            data=default(T);
            next = null;
        }


        public T Data { get; set; }

        public Node<T> Next { get; set; }




    }
}
