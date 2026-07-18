using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MyBooks.Model.Requests
{
    public class CitatUpdateRequest
    {
        public DateTime? DatumKreiranja { get; set; }
        public bool? JeOmiljeni { get; set; }
    }
}
