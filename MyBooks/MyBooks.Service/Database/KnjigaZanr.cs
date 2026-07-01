using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;

namespace MyBooks.Service.Database
{
    [Table("KnjigaZanr")]
    public partial class KnjigaZanr
    {
        [Key]
        public int Id { get; set; }
        public int IdKnjiga { get; set; }
        public int IdZanr { get; set; }

        [ForeignKey(nameof(IdKnjiga))]
        [InverseProperty(nameof(Knjiga.KnjigaZanrs))]
        public virtual Knjiga IdKnjigaNavigation { get; set; } = null!;
        [ForeignKey(nameof(IdZanr))]
        [InverseProperty(nameof(Zanr.KnjigaZanrs))]
        public virtual Zanr IdZanrNavigation { get; set; } = null!;
    }
}
