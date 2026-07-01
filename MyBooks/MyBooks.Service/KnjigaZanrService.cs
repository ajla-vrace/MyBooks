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
    public class KnjigaZanrService : BaseCRUDService<Model.KnjigaZanr, Database.KnjigaZanr, KnjigaZanrSearchObject, KnjigaZanrInsertRequest, KnjigaZanrUpdateRequest>, IKnjigaZanrService
    {
        public KnjigaZanrService(MyBooksContext context, IMapper mapper) : base(context, mapper)
        {

        }

        public override IQueryable<Database.KnjigaZanr> AddFilter(IQueryable<Database.KnjigaZanr> query, KnjigaZanrSearchObject? search = null)
        {
            var filteredQuery = base.AddFilter(query, search);

            // Ako je korisničko ime i naziv usluge uneseno

            return filteredQuery;
        }


        public override async Task<Model.KnjigaZanr> Insert(KnjigaZanrInsertRequest insert)
        {
            // Kreiraj novi entitet na osnovu request-a
            var entity = _mapper.Map<Database.KnjigaZanr>(insert);

            // Postavi trenutni datum
           // entity.DatumKreiranja = DateTime.Now;
            //entity.DatumPocetka = DateTime.Now;
            //entity.DatumZavrsetka = DateTime.Now;

            // Dodaj u bazu podataka
            _context.KnjigaZanrs.Add(entity);
            await _context.SaveChangesAsync();

            // Vrati mapirani model
            return _mapper.Map<Model.KnjigaZanr>(entity);
        }


        public override async Task<Model.KnjigaZanr> Update(int id, KnjigaZanrUpdateRequest update)
        {
            var entity = await _context.KnjigaZanrs.FindAsync(id);
            if (entity == null)
            {
                throw new KeyNotFoundException("KnjigaZanr nije pronađen.");
            }

            _mapper.Map(update, entity);


            _context.KnjigaZanrs.Update(entity);
            await _context.SaveChangesAsync();

            return _mapper.Map<Model.KnjigaZanr>(entity);
        }
    }
}
