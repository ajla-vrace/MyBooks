using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MyBooks.Model
{
    public class Zanr
    {
       public int Id { get; set; }
        public string Naziv { get; set; } = null!;
    }
}
