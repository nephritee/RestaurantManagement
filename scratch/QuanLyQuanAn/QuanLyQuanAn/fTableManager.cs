using QuanLyQuanAn.DAO;
using QuanLyQuanAn.DTO;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Globalization;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using Menu = QuanLyQuanAn.DTO.Menu;

namespace QuanLyQuanAn
{
    public partial class fTableManager : Form
    {
        public fTableManager()
        {
            InitializeComponent();

            LoadTable();
            LoadCategory();
        }

        #region Methods

        void LoadCategory()
        {
            List<Category> listCategory = CategoryDAO.Instance.GetListCategory();
            cbCategory.DataSource = listCategory;
            cbCategory.DisplayMember = "Name";
        }

        void LoadFoodListByCategoryID(int id)
        {
            List<Food> listFood = FoodDAO.Instance.GetFoodByCategoryID(id);
            cbFood.DataSource = listFood;
            cbFood.DisplayMember = "Name";
        }


        void LoadTable()
        {
            List<Table> tableList = TableDAO.Instance.LoadTableList();

            foreach (Table item in tableList) //cho mỗi 1 bàn trong list thành 1 button để dễ control
            {
                Button btn = new Button() { Width = TableDAO.TableWidth, Height = TableDAO.TableHeight }; //đặt chiều cao, ngang cho nút hiện thị bàn
                btn.Text = item.Name + Environment.NewLine + item.Status; //Đặt tên cho mỗi bàn + code xuống dòng + trạng thái bàn VD : bàn 1 trống, bàn 2 ...
                btn.Click += btn_Click; //Chọn table
                btn.Tag = item;         //để hiện bill

                switch (item.Status)
                {
                    case "Trống":
                        btn.BackColor = Color.LightGreen;
                        break;
                    default:
                        btn.BackColor = Color.LightCyan;
                        break;
                }


                flpTable.Controls.Add(btn);
            }
        } //Hiển thị cho người dùng

        void ShowBill(int id) //Lấy bill từ BillDAO
        {
            lsvBill.Items.Clear();
            List<QuanLyQuanAn.DTO.Menu> listBillInfo = MenuDAO.Instance.GetListMenuByTable(id);

            float totalPrice = 0;

            foreach (QuanLyQuanAn.DTO.Menu item in listBillInfo)
            {
                ListViewItem lsvItem = new ListViewItem(item.FoodName.ToString());
                lsvItem.SubItems.Add(item.Count.ToString());
                lsvItem.SubItems.Add(item.Price.ToString());
                lsvItem.SubItems.Add(item.TotalPrice.ToString());

                totalPrice += item.TotalPrice;

                lsvBill.Items.Add(lsvItem);
            }
            CultureInfo culture = new CultureInfo("vi"); // code thay đổi giá trị tiền sang VNĐ

            //Thread.CurrentThread.CurrentCulture = culture; -> dòng thay đổi nguồn tùy theo nơi sử dụng

            txtTotalPrice.Text = totalPrice.ToString("c", culture); //thêm culture vào thì chỉ có dòng này mới bị thay đổi nguôn nơi sử dụng

        }

        #endregion

        #region Events

        void btn_Click(object sender, EventArgs e) //Show bill cho table được chọn
        {
            int tableID = ((sender as Button).Tag as Table).ID;
            lsvBill.Tag = (sender as Button).Tag;
            ShowBill(tableID);
        }

        private void menuStrip1_ItemClicked(object sender, ToolStripItemClickedEventArgs e)
        {

        }

        private void btnAddFood_Click(object sender, EventArgs e)
        {
            Table table = lsvBill.Tag as Table;

            int idBill = BillDAO.Instance.GetUncheckBillByTableID(table.ID);

            int foodID = (cbFood.SelectedItem as Food).ID;

            int count = (int)nudFoodCount.Value;

            if (idBill == -1) //Nghĩa là không có bill
            {
                BillDAO.Instance.InsertBill(table.ID); //tạo bill cho bàn
                BillInfoDAO.Instance.InsertBillInfo(BillDAO.Instance.GetMaxIDBill(), foodID, count); //tạo thông tin cho bill đó
            }   
                
            else
            {
                BillInfoDAO.Instance.InsertBillInfo(idBill, foodID, count);
            }

            ShowBill(table.ID);
        }


        private void cbCategory_SelectedIndexChanged(object sender, EventArgs e)
        {
            int id = 0;

            ComboBox cb = sender as ComboBox;

            if (cb.SelectedItem == null)
                return;

            Category selected = cb.SelectedItem as Category;
            id = selected.ID;

            LoadFoodListByCategoryID(id);
        }


        private void menuStrip2_ItemClicked(object sender, ToolStripItemClickedEventArgs e)
        {

        }

        #endregion

        private void adminToolStripMenuItem_Click(object sender, EventArgs e)
        {
            fAdmin f = new fAdmin();
            this.Hide();
            f.ShowDialog();
            this.Show();
        }

        private void thôngTinCáNhânToolStripMenuItem_Click(object sender, EventArgs e)
        {
            fAccountProfile f = new fAccountProfile();
            f.ShowDialog();
        }

        private void đăngXuấtToolStripMenuItem_Click_1(object sender, EventArgs e)
        {
            this.Close();
        }
    }
}
