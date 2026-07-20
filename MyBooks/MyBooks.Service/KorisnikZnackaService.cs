using AutoMapper;
using MyBooks.Model.Requests;
using MyBooks.Model.SearchObject;
using MyBooks.Service.Database;
using Microsoft.EntityFrameworkCore;
using MyBooks.Model;

namespace MyBooks.Service
{
    public class KorisnikZnackaService : BaseCRUDService<Model.KorisnikZnacka, Database.KorisnikZnacka, KorisnikZnackaSearchObject, KorisnikZnackaInsertRequest, KorisnikZnackaUpdateRequest>, IKorisnikZnackaService
    {
       
        public KorisnikZnackaService(
      MyBooksContext context,
      IMapper mapper)
      : base(context, mapper)
        {
        }


        public override IQueryable<Database.KorisnikZnacka> AddFilter(
            IQueryable<Database.KorisnikZnacka> query,
            KorisnikZnackaSearchObject? search = null)
        {
            var filteredQuery = base.AddFilter(query, search);


            if (search?.IdKorisnik.HasValue == true)
            {
                filteredQuery =
                    filteredQuery.Where(x =>
                    x.KorisnikId == search.IdKorisnik);
            }


            filteredQuery = filteredQuery
                .Include(x => x.Znacka);


            return filteredQuery;
        }



        public override async Task<Model.KorisnikZnacka> Insert(KorisnikZnackaInsertRequest insert)
        {
            var postoji = await _context.KorisnikZnackas
                .AnyAsync(x =>
                    x.KorisnikId == insert.IdKorisnik &&
                    x.ZnackaId == insert.IdZnacka);


            if (postoji)
            {
                var postojeca = await _context.KorisnikZnackas
                    .FirstAsync(x =>
                        x.KorisnikId == insert.IdKorisnik &&
                        x.ZnackaId == insert.IdZnacka);

                return _mapper.Map<Model.KorisnikZnacka>(postojeca);
            }


            var entity = _mapper.Map<Database.KorisnikZnacka>(insert);

            entity.DatumOtkljucavanja = DateTime.Now;


            _context.KorisnikZnackas.Add(entity);

            await _context.SaveChangesAsync();


            return _mapper.Map<Model.KorisnikZnacka>(entity);
        }



        public override async Task<Model.KorisnikZnacka> Update(int id, KorisnikZnackaUpdateRequest update)
        {
            var entity = await _context.KorisnikZnackas.FindAsync(id);

            if (entity == null)
            {
                throw new KeyNotFoundException("KorisnikZnacka nije pronađena.");
            }


            _mapper.Map(update, entity);


            _context.KorisnikZnackas.Update(entity);

            await _context.SaveChangesAsync();


            return _mapper.Map<Model.KorisnikZnacka>(entity);
        }




        public async Task ProvjeriZnacke(int korisnikId)
        {
            // 📚 BROJ KNJIGA
            var brojKnjiga = await _context.Knjigas
                .CountAsync(x =>
                    x.KorisnikId == korisnikId);



            // 💬 BROJ CITATA
            var brojCitata = await _context.Citats
                .CountAsync(x =>
                    x.IdKnjigaNavigation.KorisnikId == korisnikId);



            // 🧭 BROJ RAZLIČITIH ŽANROVA
            var brojZanrova = await _context.KnjigaZanrs
                .Where(x =>
                    x.IdKnjigaNavigation.KorisnikId == korisnikId)
                .Select(x => x.IdZanr)
                .Distinct()
                .CountAsync();



            // ❤️ BROJ FAVORITA
            var brojFavorita = await _context.Knjigas
                .CountAsync(x =>
                    x.KorisnikId == korisnikId &&
                    x.IsFavorite == true);



            // 😊 BROJ RAZLIČITIH RASPOLOŽENJA
            var brojMoodova = await _context.Knjigas
                .Where(x =>
                    x.KorisnikId == korisnikId &&
                    x.Mood != null)
                .Select(x => x.Mood)
                .Distinct()
                .CountAsync();



            // 🔥 STREAK
            // 🔥 STREAK
            var datumiCitata = await _context.Citats
                .Where(x => x.IdKnjigaNavigation.KorisnikId == korisnikId)
                .Where(x => x.DatumKreiranja.HasValue)
                .Select(x => x.DatumKreiranja.Value.Date)
                .Distinct()
                .OrderBy(x => x)
                .ToListAsync();


            int najduziStreak = 0;
            int trenutniStreak = 0;


            for (int i = 0; i < datumiCitata.Count; i++)
            {
                if (i == 0)
                {
                    trenutniStreak = 1;
                }
                else
                {
                    var razlika =
                        (datumiCitata[i] - datumiCitata[i - 1]).Days;


                    if (razlika == 1)
                    {
                        trenutniStreak++;
                    }
                    else
                    {
                        trenutniStreak = 1;
                    }
                }


                if (trenutniStreak > najduziStreak)
                {
                    najduziStreak = trenutniStreak;
                }
            }



            // UČITAJ SVE ZNAČKE IZ BAZE
            var sveZnacke =
                await _context.Znackas
                .ToListAsync();



            foreach (var znacka in sveZnacke)
            {
                bool osvojena = false;


                switch (znacka.Tip)
                {

                    // 📚 KNJIGE
                    case "Books":

                        osvojena =
                            brojKnjiga >= znacka.Prag;

                        break;



                    // 💬 CITATI
                    case "Quotes":

                        osvojena =
                            brojCitata >= znacka.Prag;

                        break;



                    // 🧭 ŽANROVI
                    case "Genres":

                        osvojena =
                            brojZanrova >= znacka.Prag;

                        break;



                    // ❤️ FAVORITI
                    case "Favorites":

                        osvojena =
                            brojFavorita >= znacka.Prag;

                        break;



                    // 😊 MOOD
                    case "Mood":

                        osvojena =
                            brojMoodova >= znacka.Prag;

                        break;



                    // 🔥 STREAK
                    case "Streak":

                        osvojena =
                            najduziStreak >= znacka.Prag;

                        break;
                }



                if (osvojena)
                {
                    await DodajZnackuAkoNema(
                        korisnikId,
                        znacka.Id
                    );
                }
            }
        }



        private async Task DodajZnackuAkoNema(
            int korisnikId,
            int znackaId)
        {

            var postoji =
                await _context.KorisnikZnackas
                .AnyAsync(x =>
                    x.KorisnikId == korisnikId &&
                    x.ZnackaId == znackaId);



            if (!postoji)
            {

                _context.KorisnikZnackas.Add(
                    new Database.KorisnikZnacka
                    {
                        KorisnikId = korisnikId,
                        ZnackaId = znackaId,
                        DatumOtkljucavanja = DateTime.Now
                    });


                await _context.SaveChangesAsync();
            }
        }
        public async Task<Model.Znacka?> GetSljedecaZnacka(int idKorisnik)
        {
            // sve značke
            var databaseZnacke = await _context.Znackas
                .ToListAsync();


            // značke koje korisnik već ima
            var osvojeneIds = await _context.KorisnikZnackas
                .Where(x => x.KorisnikId == idKorisnik)
                .Select(x => x.ZnackaId)
                .ToListAsync();



            var rezultat = new List<Model.Znacka>();


            foreach (var dbZnacka in databaseZnacke)
            {

                // preskoči već osvojene
                if (osvojeneIds.Contains(dbZnacka.Id))
                    continue;



                var znacka = _mapper.Map<Model.Znacka>(dbZnacka);


                znacka.TrenutniNapredak =
                    await IzracunajNapredak(idKorisnik, dbZnacka);


                rezultat.Add(znacka);
            }



            return rezultat
                .Where(x => x.Preostalo > 0)
                .OrderBy(x => x.Preostalo)
                .FirstOrDefault();
        }
        private async Task<int> IzracunajNapredak(
    int korisnikId,
    Database.Znacka znacka)
        {
            switch (znacka.Tip)
            {
                case "Books":
                    return await _context.Knjigas
                        .CountAsync(x => x.KorisnikId == korisnikId);


                case "Quotes":
                    return await _context.Citats
                        .CountAsync(x =>
                            x.IdKnjigaNavigation.KorisnikId == korisnikId);


                case "Genres":
                    return await _context.KnjigaZanrs
                        .Where(x =>
                            x.IdKnjigaNavigation.KorisnikId == korisnikId)
                        .Select(x => x.IdZanr)
                        .Distinct()
                        .CountAsync();


                case "Favorites":
                    return await _context.Knjigas
                        .CountAsync(x =>
                            x.KorisnikId == korisnikId &&
                            x.IsFavorite == true);


                case "Mood":
                    return await _context.Knjigas
                        .Where(x =>
                            x.KorisnikId == korisnikId &&
                            x.Mood != null)
                        .Select(x => x.Mood)
                        .Distinct()
                        .CountAsync();


                case "Streak":
                    return await IzracunajStreak(korisnikId);


                default:
                    return 0;
            }
        }
        private async Task<int> IzracunajStreak(int korisnikId)
        {
            var datumiCitata = await _context.Citats
                .Where(x => x.IdKnjigaNavigation.KorisnikId == korisnikId)
                .Where(x => x.DatumKreiranja.HasValue)
                .Select(x => x.DatumKreiranja.Value.Date)
                .Distinct()
                .OrderBy(x => x)
                .ToListAsync();


            int najduziStreak = 0;
            int trenutniStreak = 0;


            for (int i = 0; i < datumiCitata.Count; i++)
            {
                if (i == 0)
                {
                    trenutniStreak = 1;
                }
                else
                {
                    var razlika =
                        (datumiCitata[i] - datumiCitata[i - 1]).Days;


                    if (razlika == 1)
                    {
                        trenutniStreak++;
                    }
                    else
                    {
                        trenutniStreak = 1;
                    }
                }


                if (trenutniStreak > najduziStreak)
                {
                    najduziStreak = trenutniStreak;
                }
            }


            return najduziStreak;
        }
    }
}