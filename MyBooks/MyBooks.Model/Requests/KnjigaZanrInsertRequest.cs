using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MyBooks.Model.Requests
{
    public class KnjigaZanrInsertRequest
    {
        public int IdKnjiga { get; set; }
        public int IdZanr { get; set; }
    }
}
