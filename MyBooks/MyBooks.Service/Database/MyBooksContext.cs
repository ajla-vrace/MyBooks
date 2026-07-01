using System;
using System.Collections.Generic;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata;

namespace MyBooks.Service.Database
{
    public partial class MyBooksContext : DbContext
    {
        public MyBooksContext()
        {
        }

        public MyBooksContext(DbContextOptions<MyBooksContext> options)
            : base(options)
        {
        }

        public virtual DbSet<Citat> Citats { get; set; } = null!;
        public virtual DbSet<Knjiga> Knjigas { get; set; } = null!;
        public virtual DbSet<KnjigaZanr> KnjigaZanrs { get; set; } = null!;
        public virtual DbSet<WishKnjiga> WishKnjigas { get; set; } = null!;
        public virtual DbSet<Zanr> Zanrs { get; set; } = null!;

        protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
        {
            if (!optionsBuilder.IsConfigured)
            {
#warning To protect potentially sensitive information in your connection string, you should move it out of source code. You can avoid scaffolding the connection string by using the Name= syntax to read it from configuration - see https://go.microsoft.com/fwlink/?linkid=2131148. For more guidance on storing connection strings, see http://go.microsoft.com/fwlink/?LinkId=723263.
                optionsBuilder.UseSqlServer("Server=.;Database=MyBooks;Trusted_Connection=True;TrustServerCertificate=True;");
            }
        }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<Citat>(entity =>
            {
                entity.Property(e => e.DatumKreiranja).HasDefaultValueSql("(getdate())");

                entity.Property(e => e.JeOmiljeni).HasDefaultValueSql("((0))");

                entity.HasOne(d => d.IdKnjigaNavigation)
                    .WithMany(p => p.Citats)
                    .HasForeignKey(d => d.IdKnjiga)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK__Citat__IdKnjiga__29572725");
            });

            modelBuilder.Entity<Knjiga>(entity =>
            {
                entity.Property(e => e.DatumKreiranja).HasDefaultValueSql("(getdate())");
            });

            modelBuilder.Entity<KnjigaZanr>(entity =>
            {
                entity.HasOne(d => d.IdKnjigaNavigation)
                    .WithMany(p => p.KnjigaZanrs)
                    .HasForeignKey(d => d.IdKnjiga)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK__KnjigaZan__IdKnj__2E1BDC42");

                entity.HasOne(d => d.IdZanrNavigation)
                    .WithMany(p => p.KnjigaZanrs)
                    .HasForeignKey(d => d.IdZanr)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK__KnjigaZan__IdZan__2F10007B");
            });

            modelBuilder.Entity<WishKnjiga>(entity =>
            {
                entity.Property(e => e.DatumKreiranja).HasDefaultValueSql("(getdate())");
            });

            OnModelCreatingPartial(modelBuilder);
        }

        partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
    }
}
