using QuanLyQuanAn.DAO;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Data.SqlClient;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace QuanLyQuanAn
{
    public partial class fAdmin : Form
    {
        public fAdmin()
        {
            InitializeComponent();

            LoadAccountList();
        }

        void LoadFoodList()
        {
            string query = "SELECT * FROM food";

            dgvFood.DataSource = DataProvider.Instance.ExecuteQuery(query, new object[] { "tintin5b" });
        }

        void LoadAccountList()
        {
            string query = "EXEC dbo.USP_GetAccountByUserName @userName";

            dgvAccount.DataSource = DataProvider.Instance.ExecuteQuery(query, new object[] { "tintin5b" });
        }

        private void tpAccount_Click(object sender, EventArgs e)
        {

        }

        private void panel8_Paint(object sender, PaintEventArgs e)
        {

        }
    }
}
