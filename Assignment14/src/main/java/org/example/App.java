package org.example;

import java.io.IOException;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.MapWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.mapreduce.Reducer;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.log4j.BasicConfigurator;

public class App {

    public static class TokenizerMapper extends Mapper<Object, Text, Text, MapWritable> {

        private Text pid = new Text();
        private MapWritable mw = new MapWritable();

        public void map(Object key, Text value, Context context) throws IOException, InterruptedException {

            String[] attr = value.toString().split(",");
            try {
                pid = new Text(attr[0]);//player id
                mw.put(new IntWritable(1), new IntWritable(Integer.parseInt(attr[8])));//hits
                mw.put(new IntWritable(2), new IntWritable(Integer.parseInt(attr[1])));//year
                mw.put(new IntWritable(3), new IntWritable(Integer.parseInt(attr[6])));//at bats

                context.write(pid, mw);
            } catch (Exception e) {

            }
        }
    }

    public static class IntSumReducer
            extends Reducer<Text, IntWritable, Text, IntWritable> {
        private IntWritable result = new IntWritable();

        public void reduce(Text key, Iterable<MapWritable> values, Context context) throws IOException, InterruptedException {

            int totHits = 0;
            int totAB = 0;

            for (MapWritable value : values) {
                int hits = ((IntWritable) value.get(new IntWritable(1))).get();
                int year = ((IntWritable) value.get(new IntWritable(2))).get();
                int ab = ((IntWritable) value.get(new IntWritable(3))).get();

                if (year > 1900) {
                    totHits += hits;
                    totAB += ab;
                }
            }
            result.set(totHits / totAB);
            context.write(key, result);
        }
    }

    public static void main(String[] args) throws Exception {
        BasicConfigurator.configure();

        Configuration conf = new Configuration();
        Job job = Job.getInstance(conf, "app");
        job.setJarByClass(App.class);
        job.setMapperClass(TokenizerMapper.class);
        job.setCombinerClass(IntSumReducer.class);
        job.setReducerClass(IntSumReducer.class);
        job.setOutputKeyClass(Text.class);
        job.setOutputValueClass(MapWritable.class);
        FileInputFormat.addInputPath(job, new Path(args[0]));
        FileOutputFormat.setOutputPath(job, new Path(args[1]));
        System.exit(job.waitForCompletion(true) ? 0 : 1);
    }
}

