using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace QuanLyQuanAn.DTO
{
    public class Menu
    {
        
        public Menu(string foodName, int count, float price, float totalPrice = 0)
        {
            this.foodName = FoodName;
            this.count = Count;
            this.price = Price;
            this.totalPrice = TotalPrice;
        }

        public Menu(DataRow row)
        {
            this.foodName = row["Name"].ToString();
            this.count = (int)row["count"];
            this.price = (float)Convert.ToDouble(row["price"].ToString());              //Mặc dù kquả ra là flot nhưng bị lỗi nên phải convert qua double rồi từ double qua float 
            this.totalPrice = (float)Convert.ToDouble(row["totalPrice"].ToString());    //vì nếu không sẽ bị lỗi ở CSharp 
        }

        private float totalPrice;

        public float TotalPrice
        {
            get { return totalPrice; }
            set { totalPrice = value; }
        }

        private float price;

        public float Price
        {
            get { return price; }
            set { price = value; }
        }

        private int count;

        public int Count
        {
            get { return count; }
            set { count = value; }
        }

        private string foodName;
        public string FoodName
        {
            get { return foodName; }
            set { foodName = value; }
        }
    }
}
