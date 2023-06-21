using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace QuanLyQuanAn.DTO
{
    public class Category
    {

        public Category(int id, string name)
        {
            this.ID = iD;
            this.Name = name;
        }

        public Category(DataRow row)
        {
            this.iD = (int)row["id"];
            this.name = row["name"].ToString();
        }

        private string name;

        public string Name
        {
            get { return name; }
            set { name = value; }
        }

        private int iD;

        public int ID
        {
            get { return iD; }
            set { iD = value; }
        }
    }
}
