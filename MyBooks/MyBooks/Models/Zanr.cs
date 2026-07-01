using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;

namespace MyBooks.Models
{
    [Table("Zanr")]
    public partial class Zanr
    {
        public Zanr()
        {
            KnjigaZanrs = new HashSet<KnjigaZanr>();
        }

        [Key]
        public int Id { get; set; }
        [StringLength(100)]
        public string Naziv { get; set; } = null!;

        [InverseProperty(nameof(KnjigaZanr.IdZanrNavigation))]
        public virtual ICollection<KnjigaZanr> KnjigaZanrs { get; set; }
    }
}
