using AutoMapper;
using MyBooks.Model.Requests;
using MyBooks.Model.SearchObject;
using MyBooks.Service.Database;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using MyBooks.Model;
using MyBooks.Service;

namespace MyBooks.Service
{
    public class WishKnjigaService : BaseCRUDService<Model.WishKnjiga, Database.WishKnjiga, WishKnjigaSearchObject, WishKnjigaInsertRequest, WishKnjigaUpdateRequest>, IWishKnjigaService
    {
        public WishKnjigaService(MyBooksContext context, IMapper mapper) : base(context, mapper)
        {

        }

        public override IQueryable<Database.WishKnjiga> AddFilter(IQueryable<Database.WishKnjiga> query, WishKnjigaSearchObject? search = null)
        {
            var filteredQuery = base.AddFilter(query, search);

            // Ako je korisničko ime i naziv usluge uneseno

            return filteredQuery;
        }


        public override async Task<Model.WishKnjiga> Insert(WishKnjigaInsertRequest insert)
        {
            // Kreiraj novi entitet na osnovu request-a
            var entity = _mapper.Map<Database.WishKnjiga>(insert);

            if (!string.IsNullOrEmpty(insert.SlikaBase64))
            {
                entity.Slika = Convert.FromBase64String(insert.SlikaBase64);
            }

            // Postavi trenutni datum
            entity.DatumKreiranja = DateTime.Now;
            //entity.DatumPocetka = DateTime.Now;
            //entity.DatumZavrsetka = DateTime.Now;

            // Dodaj u bazu podataka
            _context.WishKnjigas.Add(entity);
            await _context.SaveChangesAsync();

            // Vrati mapirani model
            return _mapper.Map<Model.WishKnjiga>(entity);
        }


        public override async Task<Model.WishKnjiga> Update(int id, WishKnjigaUpdateRequest update)
        {
            var entity = await _context.WishKnjigas.FindAsync(id);
            if (entity == null)
            {
                throw new KeyNotFoundException("WishKnjiga nije pronađen.");
            }

            _mapper.Map(update, entity);


            _context.WishKnjigas.Update(entity);
            await _context.SaveChangesAsync();

            return _mapper.Map<Model.WishKnjiga>(entity);
        }
    }
}
