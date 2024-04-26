using System;
using System.Collections.Generic;

using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

using System.Data.SqlClient;

namespace test_json
{
    public partial class api : System.Web.UI.Page
    {
        const string CNSTR = "Server=127.0.0.1,49259;Database=QLSV;User Id=sa;Password=123;";
        void list_user(string action)
        {
            //input: none
            //output: json trong sp_user
            
            SqlConnection cn=new SqlConnection(CNSTR);
            cn.Open();
            SqlCommand cmd = new SqlCommand("sp_user", cn);
            cmd.CommandType = System.Data.CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@action", action);
            string json = (string)cmd.ExecuteScalar();
            this.Response.Write(json);
            cmd.Dispose();
            cn.Close();
            cn.Dispose();
        }
        void check_login(string action)
        {
            //input: uid,pwd
            //output: json trong sp_user

            SqlConnection cn = new SqlConnection(CNSTR);
            cn.Open();
            SqlCommand cmd = new SqlCommand("sp_user", cn);
            cmd.CommandType = System.Data.CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@action", action);
            cmd.Parameters.AddWithValue("@uid", Request["uid"]);
            cmd.Parameters.AddWithValue("@pwd", Request["pwd"]);
            string json = (string)cmd.ExecuteScalar();
            this.Response.Write(json);
            cmd.Dispose();
            cn.Close();
            cn.Dispose();
        }
        protected void Page_Load(object sender, EventArgs e)
        {
            string action = this.Request["action"];
            this.Request.ContentType = "application/json";
            switch (action)
            {
                case "list_user":
                    list_user(action);
                    break;
                case "check_login":
                    check_login(action);
                    break;
            }
        }
    }
}