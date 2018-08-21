global class GeocodingAccountBatchSched implements Schedulable {
    global void execute(SchedulableContext sc) {
        GeocodingAccountBatch process = new  GeocodingAccountBatch();
        Database.executeBatch(process, 1);
    }
}